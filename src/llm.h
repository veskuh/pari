#ifndef LLM_H
#define LLM_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class Llm : public QObject
{
    Q_OBJECT
public:
    explicit Llm(QObject *parent = nullptr);

public slots:
    void sendPrompt(const QString &prompt);

signals:
    void responseReady(const QString &response);
    void newLineReceived(const QString &line);

private slots:
    void onNetworkReply();
    void onReadyRead();

private:
    QNetworkAccessManager *m_networkAccessManager;
    bool m_busy;
    QByteArray m_buffer;
    QString m_currentResponse;
    QString m_partialLine;

    Q_PROPERTY(bool busy READ busy WRITE setBusy NOTIFY busyChanged)

public:
    bool busy() const;
    void setBusy(bool busy);

signals:
    void busyChanged();
};

#endif // LLM_H
