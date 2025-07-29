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

private slots:
    void onNetworkReply(QNetworkReply *reply);

private:
    QNetworkAccessManager *m_networkAccessManager;
    bool m_busy;

    Q_PROPERTY(bool busy READ busy WRITE setBusy NOTIFY busyChanged)

public:
    bool busy() const;
    void setBusy(bool busy);

signals:
    void busyChanged();
};

#endif // LLM_H
