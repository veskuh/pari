#include "llm.h"
#include <QNetworkRequest>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>
#include <QEventLoop>
#include <QDateTime>
#include <QRegularExpression>

void Llm::addToChatLog(const QString &line)
{
    m_chatLog.append(QString("[%1] %2").arg(QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss")).arg(line));
    emit chatLogChanged();
}

Llm::Llm(Settings *settings, QObject *parent)
    : QObject{parent}
    , m_settings(settings)
    , m_busy(false)
    , m_partialLine("")
{
    m_networkAccessManager = new QNetworkAccessManager(this);
    connect(m_networkAccessManager, &QNetworkAccessManager::finished, this, &Llm::onNetworkReply);

    if (m_settings) {
        connect(m_settings, &Settings::ollamaUrlChanged, this, &Llm::onSettingsChanged);
        connect(m_settings, &Settings::ollamaModelChanged, this, &Llm::onSettingsChanged);
    }
}

QStringList Llm::chatLog() const
{
    return m_chatLog;
}

bool Llm::busy() const
{
    return m_busy;
}

void Llm::setBusy(bool busy)
{
    if (m_busy == busy)
        return;
    m_busy = busy;
    emit busyChanged();
}

void Llm::sendPrompt(const QString &prompt)
{
    setBusy(true);

    addToChatLog("USER: " + prompt);

    QNetworkRequest request(QUrl(m_settings->ollamaUrl() + "/api/generate"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject mainObject;
    mainObject["model"] = m_settings->ollamaModel();
    mainObject["prompt"] = prompt;
    mainObject["stream"] = true;

    QJsonDocument doc(mainObject);
    QByteArray data = doc.toJson();

    QNetworkReply *reply = m_networkAccessManager->post(request, data);
    connect(reply, &QNetworkReply::readyRead, this, &Llm::onReadyRead);
    connect(reply, &QNetworkReply::finished, this, &Llm::onNetworkReply);

    m_currentResponse.clear(); // Clear previous response
    m_partialLine.clear(); // Clear partial line buffer
}

void Llm::onSettingsChanged()
{
    addToChatLog(QString("INFO: Settings changed. New URL: %1, New Model: %2")
                     .arg(m_settings->ollamaUrl())
                     .arg(m_settings->ollamaModel()));
    qDebug() << "Llm settings changed.";
}

void Llm::onReadyRead()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply)
        return;

    QByteArray newData = reply->readAll();
    m_buffer.append(newData);

    while (m_buffer.contains("\n")) {
        int newlineIndex = m_buffer.indexOf("\n");
        QByteArray lineData = m_buffer.left(newlineIndex + 1);
        m_buffer.remove(0, newlineIndex + 1);

        QJsonDocument jsonDoc = QJsonDocument::fromJson(lineData);
        if (!jsonDoc.isNull() && jsonDoc.isObject()) {
            QJsonObject jsonObj = jsonDoc.object();
            if (jsonObj.contains("response")) {
                QString newText = jsonObj["response"].toString();
                m_currentResponse.append(newText);
                m_partialLine.append(newText);

                // Check for newlines within the received text
                int lineBreakIndex = m_partialLine.indexOf('\n');
                while (lineBreakIndex != -1) {
                    QString completeLine = m_partialLine.left(lineBreakIndex);
                    emit newLineReceived(completeLine);
                    m_partialLine.remove(0, lineBreakIndex + 1);
                    lineBreakIndex = m_partialLine.indexOf('\n');
                }
            }
        }
    }
}

void Llm::onNetworkReply()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply)
        return;

    setBusy(false);
    qDebug() << "onNetworkReply called, busy:" << m_busy;
    if (reply->error() == QNetworkReply::NoError) {
        // Process any remaining data in the buffer
        onReadyRead();

        // Emit any remaining partial line as a final line
        if (!m_partialLine.isEmpty()) {
            emit newLineReceived(m_partialLine);
            m_partialLine.clear();
        }
        addToChatLog("AI: " + m_currentResponse);
        QString finalResponse = m_currentResponse;
        finalResponse.replace(QRegularExpression("<think>.*?</think>", QRegularExpression::DotMatchesEverythingOption), "");
        emit responseReady(finalResponse);
    } else {
        qDebug() << "Network error: " << reply->errorString();
        addToChatLog("ERROR: " + reply->errorString());
        emit responseReady("Error: " + reply->errorString());
    }
    reply->deleteLater();
}

void Llm::listModels()
{
    QNetworkRequest request(QUrl(m_settings->ollamaUrl() + "/api/tags"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QNetworkReply *reply = m_networkAccessManager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if (reply->error() == QNetworkReply::NoError) {
            QByteArray data = reply->readAll();
            QJsonDocument doc = QJsonDocument::fromJson(data);
            QJsonObject obj = doc.object();
            QJsonArray modelsArray = obj["models"].toArray();
            QStringList models;
            for (const auto &modelValue : modelsArray) {
                QJsonObject modelObject = modelValue.toObject();
                models.append(modelObject["name"].toString());
            }
            emit modelsListed(models);
        } else {
            qDebug() << "Error listing models:" << reply->errorString();
        }
        reply->deleteLater();
    });
}
