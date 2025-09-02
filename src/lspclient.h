#ifndef LSPCLIENT_H
#define LSPCLIENT_H

#include <QObject>
#include <QProcess>
#include <QJsonObject>

class LspClient : public QObject
{
    Q_OBJECT
public:
    explicit LspClient(QObject *parent = nullptr);
    ~LspClient();

    Q_INVOKABLE void startServer(const QString &projectPath);
    Q_INVOKABLE void documentOpened(const QString &documentPath, const QString &content);
    Q_INVOKABLE void documentChanged(const QString &documentPath, const QString &content);
    Q_INVOKABLE void requestCompletion(const QString &documentPath, int line, int character);
    Q_INVOKABLE void format(const QString &documentPath, const QString &content);
    Q_INVOKABLE void stopServer();

signals:
    void completionItems(const QList<QString> &items);
    void formattingResult(const QString &result);

private slots:
    void onReadyRead();
    void onReadyReadStandardError();
    void onProcessError(QProcess::ProcessError error);

private:
    void sendMessage(const QJsonObject &message);
    void handleMessage(const QByteArray &message);
    qint64 positionToIndex(const QJsonObject &position, const QString &document);

    QProcess *m_process;
    int m_requestId;
    int m_documentId;
    QString m_formattingDocumentContent;
};

#endif // LSPCLIENT_H
