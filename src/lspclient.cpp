#include "lspclient.h"
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonValue>
#include <QDebug>
#include <QCoreApplication>

LspClient::LspClient(QObject *parent) : QObject(parent), m_process(nullptr), m_requestId(0), m_documentId(0)
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

void LspClient::format(const QString &documentPath, const QString &content)
{
    m_formattingDocumentContent = content;
    QJsonObject textDocument;
    textDocument["uri"] = QUrl::fromLocalFile(documentPath).toString();

    QJsonObject options;
    options["tabSize"] = 4;
    options["insertSpaces"] = true;

    QJsonObject params;
    params["textDocument"] = textDocument;
    params["options"] = options;

    QJsonObject message;
    message["jsonrpc"] = "2.0";
    message["id"] = m_requestId++;
    message["method"] = "textDocument/formatting";
    message["params"] = params;

    sendMessage(message);
}

void LspClient::documentOpened(const QString &documentPath, const QString &content)
{
    QJsonObject textDocument;
    textDocument["uri"] = QUrl::fromLocalFile(documentPath).toString();
    textDocument["languageId"] = "cpp";
    m_documentId = 1;
    textDocument["version"] = m_documentId++;
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
    textDocument["version"] = m_documentId++; 

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

qint64 LspClient::positionToIndex(const QJsonObject &position, const QString &document)
{
    qint64 line = position["line"].toInt();
    qint64 character = position["character"].toInt();
    qint64 index = 0;
    for (qint64 i = 0; i < line; ++i) {
        index = document.indexOf('\n', index) + 1;
        if (index == 0) return -1; // Line not found
    }
    return index + character;
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
        QJsonValue resultValue = obj.value("result");
        if (resultValue.isObject()) {
            QJsonObject result = resultValue.toObject();
            if (result.contains("items")) {
                QJsonArray items = result["items"].toArray();
                QList<QString> completionItemsList;
                for (const QJsonValue &item : items) {
                    completionItemsList.append(item.toObject()["label"].toString());
                }
                emit completionItems(completionItemsList);
            }
        } else if (resultValue.isArray()) {
            QString newText = m_formattingDocumentContent;
            const QJsonArray edits = resultValue.toArray();
            for (int i = edits.size() - 1; i >= 0; --i) {
                const QJsonObject edit = edits[i].toObject();
                const QJsonObject range = edit["range"].toObject();
                const qint64 start = positionToIndex(range["start"].toObject(), newText);
                const qint64 end = positionToIndex(range["end"].toObject(), newText);
                if (start < 0 || end < 0 || start > end) {
                    qWarning() << "Invalid range in formatting response";
                    continue;
                }
                newText.remove(start, end - start);
                newText.insert(start, edit["newText"].toString());
            }
            emit formattingResult(newText);
        }
    }
}
