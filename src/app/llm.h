#ifndef LLM_H
#define LLM_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include "settings.h"
#include "markdownformatter.h"

class Llm : public QObject
{
    Q_OBJECT
public:
    explicit Llm(Settings *settings, QObject *parent = nullptr);
    bool busy() const;
    void setBusy(bool busy);
    QStringList chatLog() const;

public slots:
    void sendPrompt(const QString &prompt);
    void listModels();

signals:
    void responseReady(const QString &response);
    void newLineReceived(const QString &line);
    void modelsListed(const QStringList &models);
    void chatLogChanged();
    void busyChanged();

private slots:
    void onNetworkReply();
    void onReadyRead();
    void onSettingsChanged();

private:
    void addToChatLog(const QString &line);
    QNetworkAccessManager *m_networkAccessManager;
    Settings *m_settings;
    bool m_busy;
    QByteArray m_buffer;
    QString m_currentResponse;
    QString m_partialLine;
    
    QStringList m_chatLog;

    Q_PROPERTY(bool busy READ busy WRITE setBusy NOTIFY busyChanged)
    Q_PROPERTY(QStringList chatLog READ chatLog NOTIFY chatLogChanged)

};

#endif // LLM_H
