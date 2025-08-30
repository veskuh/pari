#include "lspclient.h"
#include <QJsonDocument>
#include <QJsonArray>
#include <QDebug>
#include <QCoreApplication>

LspClient::LspClient(QObject *parent) : QObject(parent), m_process(new QProcess(this)), m_requestId(0)
{
    connect(m_process, &QProcess::readyRead, this, &LspClient::onReadyRead);
    connect(m_process, &QProcess::errorOccurred, this, &LspClient::onProcessError);
}

LspClient::~LspClient()
{
    m_process->kill();
}

void LspClient::startServer(const QString &projectPath)
{
    QStringList args;
    args << "--compile-commands-dir=" + projectPath + "/build";
    m_process->start("clangd", args);
    if (!m_process->waitForStarted()) {
        qWarning() << "Failed to start clangd:" << m_process->errorString();
        return;
    }

    QJsonObject initializeParams;
    initializeParams["processId"] = QCoreApplication::applicationPid();
    initializeParams["rootUri"] = QUrl::fromLocalFile(projectPath).toString();
    QJsonObject capabilities;
    // Add capabilities here if needed
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
    // For now, we are re-opening the document on every change.
    // A more advanced implementation would send incremental changes.
    documentOpened(documentPath, content);
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
    QByteArray data = m_process->readAll();
    handleMessage(data);
}

void LspClient::onProcessError(QProcess::ProcessError error)
{
    qWarning() << "clangd process error:" << error << m_process->errorString();
}

void LspClient::sendMessage(const QJsonObject &message)
{
    QJsonDocument doc(message);
    QByteArray bytes = doc.toJson(QJsonDocument::Compact);
    QString header = QString("Content-Length: %1\r\n\r\n").arg(bytes.length());
    m_process->write(header.toUtf8());
    m_process->write(bytes);
}

void LspClient::handleMessage(const QByteArray &message)
{
    // This is a simplified parser. A real implementation would need to handle
    // chunked messages and headers properly.
    QString messageStr(message);
    QStringList parts = messageStr.split("\r\n\r\n");
    if (parts.size() < 2) {
        return;
    }
    QJsonDocument doc = QJsonDocument::fromJson(parts[1].toUtf8());
    QJsonObject obj = doc.object();

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
