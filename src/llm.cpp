#include "llm.h"
#include <QNetworkRequest>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>
#include <QEventLoop>

Llm::Llm(QObject *parent)
    : QObject{parent}
    , m_busy(false)
{
    qDebug() << "Llm initialized, busy:" << m_busy;
    m_networkAccessManager = new QNetworkAccessManager(this);
    connect(m_networkAccessManager, &QNetworkAccessManager::finished, this, &Llm::onNetworkReply);
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
    qDebug() << "sendPrompt called, busy:" << m_busy;
    QNetworkRequest request(QUrl("http://localhost:11434/api/generate"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject mainObject;
    mainObject["model"] = "gemma3:12b"; // Or any other model you have locally
    mainObject["prompt"] = prompt;
    mainObject["stream"] = false;

    QJsonDocument doc(mainObject);
    QByteArray data = doc.toJson();

    qDebug() << "Sending request:" << QString(data);

    m_networkAccessManager->post(request, data);

    // The reply is processed in onNetworkReply, which is connected to finished signal
    // No need to delete reply here, it's handled in onNetworkReply
}

void Llm::onNetworkReply(QNetworkReply *reply)
{
    setBusy(false);
    qDebug() << "onNetworkReply called, busy:" << m_busy;
    if (reply->error() == QNetworkReply::NoError) {
        QByteArray responseData = reply->readAll();
        qDebug() << "Received response:" << QString(responseData);
        QJsonDocument jsonDoc = QJsonDocument::fromJson(responseData);
        QJsonObject jsonObj = jsonDoc.object();

        if (jsonObj.contains("response")) {
            emit responseReady(jsonObj["response"].toString());
        } else {
            emit responseReady("Error: Unexpected API response format.");
        }
    } else {
        qDebug() << "Network error:" << reply->errorString();
        emit responseReady("Error: " + reply->errorString());
    }
    reply->deleteLater();
}