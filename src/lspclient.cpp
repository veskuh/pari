#include "lspclient.h"
#include <QJsonDocument>
#include <QJsonArray>
#include <QDebug>
#include <QCoreApplication>

LspClient::LspClient(QObject *parent) : QObject(parent), m_process(nullptr), m_requestId(0)
{
}

LspClient::~LspClient()
{
    if (m_process) {
        m_process->kill();
        m_process->waitForFinished();
        m_process->deleteLater();
    }
}

void LspClient::startServer(const QString &projectPath)
{
    if (m_process) {
        m_process->kill();
        m_process->waitForFinished();
        m_process->deleteLater();
    }

    m_process = new QProcess(this);
    connect(m_process, &QProcess::readyRead, this, &LspClient::onReadyRead);
    connect(m_process, &QProcess::readyReadStandardError, this, &LspClient::onReadyReadStandardError);
    connect(m_process, &QProcess::errorOccurred, this, &LspClient::onProcessError);

    m_process->setWorkingDirectory(projectPath);
    QStringList args;
    args << "--compile-commands-dir=" + projectPath + "/build";
    args << "--log=verbose";
    m_process->start("clangd", args);
    if (!m_process->waitForStarted()) {
        qWarning() << "Failed to start clangd:" << m_process->errorString();
        return;
    }

    QJsonObject initializeParams;
    initializeParams["processId"] = QCoreApplication::applicationPid();
    initializeParams["rootUri"] = QUrl::fromLocalFile(projectPath).toString();
    QJsonObject capabilities;
    QJsonObject textDocument;
    QJsonObject completion;
    QJsonObject completionItem;
    completionItem["snippetSupport"] = true;
    completion["completionItem"] = completionItem;
    textDocument["completion"] = completion;
    capabilities["textDocument"] = textDocument;
    initializeParams["capabilities"] = capabilities;

    QJsonObject message;
    message["jsonrpc"] = "2.0";
    message["id"] = m_requestId++;
    message["method"] = "initialize";
    message["params"] = initializeParams;

    sendMessage(message);
}

void LspClient::documentOpened(const QString &documentPath, const QString &content)
{
    QJsonObject textDocument;
    textDocument["uri"] = QUrl::fromLocalFile(documentPath).toString();
    textDocument["languageId"] = "cpp";
    textDocument["version"] = 1;
    textDocument["text"] = content;

    QJsonObject params;
    params["textDocument"] = textDocument;

    QJsonObject message;
    message["jsonrpc"] = "2.0";
    message["method"] = "textDocument/didOpen";
    message["params"] = params;

    sendMessage(message);
}

void LspClient::documentChanged(const QString &documentPath, const QString &content)
{
    QJsonObject textDocument;
    textDocument["uri"] = QUrl::fromLocalFile(documentPath).toString();
    textDocument["version"] = 2; // Version number should be incremented

    QJsonObject contentChanges;
    contentChanges["text"] = content;

    QJsonArray contentChangesArray;
    contentChangesArray.append(contentChanges);

    QJsonObject params;
    params["textDocument"] = textDocument;
    params["contentChanges"] = contentChangesArray;

    QJsonObject message;
    message["jsonrpc"] = "2.0";
    message["method"] = "textDocument/didChange";
    message["params"] = params;

    sendMessage(message);
}

void LspClient::requestCompletion(const QString &documentPath, int line, int character)
{
    QJsonObject textDocument;
    textDocument["uri"] = QUrl::fromLocalFile(documentPath).toString();

    QJsonObject position;
    position["line"] = line;
    position["character"] = character;

    QJsonObject params;
    params["textDocument"] = textDocument;
    params["position"] = position;

    QJsonObject message;
    message["jsonrpc"] = "2.0";
    message["id"] = m_requestId++;
    message["method"] = "textDocument/completion";
    message["params"] = params;

    sendMessage(message);
}

void LspClient::onReadyRead()
{
    if (!m_process) return;
    QByteArray data = m_process->readAll();
    handleMessage(data);
}

void LspClient::onReadyReadStandardError()
{
    if (!m_process) return;
    qDebug() << "clangd stderr:" << m_process->readAllStandardError();
}

void LspClient::onProcessError(QProcess::ProcessError error)
{
    if (!m_process) return;
    qWarning() << "clangd process error:" << error << m_process->errorString();
}

void LspClient::sendMessage(const QJsonObject &message)
{
    if (!m_process) return;
    QJsonDocument doc(message);
    QByteArray bytes = doc.toJson(QJsonDocument::Compact);
    qDebug() << "-->" << doc.toJson(QJsonDocument::Indented);
    QString header = QString("Content-Length: %1\r\n\r\n").arg(bytes.length());
    m_process->write(header.toUtf8());
    m_process->write(bytes);
}

void LspClient::handleMessage(const QByteArray &message)
{
    QString messageStr(message);
    QStringList parts = messageStr.split("\r\n\r\n");
    if (parts.size() < 2) {
        return;
    }
    QJsonDocument doc = QJsonDocument::fromJson(parts[1].toUtf8());
    QJsonObject obj = doc.object();

    qDebug() << "<--" << doc.toJson(QJsonDocument::Indented);

    if (obj.contains("result")) {
        QJsonObject result = obj["result"].toObject();
        if (result.contains("items")) {
            QJsonArray items = result["items"].toArray();
            QList<QString> completionItemsList;
            for (const QJsonValue &item : items) {
                completionItemsList.append(item.toObject()["label"].toString());
            }
            emit completionItems(completionItemsList);
        }
    }
}
