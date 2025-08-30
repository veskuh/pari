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

    bool isServerRunning() const;
    QString projectPath() const;

signals:
    void completionItems(const QList<QString> &items);

private slots:
    void onReadyRead();
    void onProcessError(QProcess::ProcessError error);

private:
    void sendMessage(const QJsonObject &message);
    void handleMessage(const QByteArray &message);

    QProcess *m_process;
    int m_requestId;
    QString m_projectPath;
};

#endif // LSPCLIENT_H
