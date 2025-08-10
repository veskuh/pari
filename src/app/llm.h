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

public slots:
    void sendPrompt(const QString &prompt);
    void listModels();

signals:
    void responseReady(const QString &response);
    void newLineReceived(const QString &line);
    void modelsListed(const QStringList &models);

private slots:
    void onNetworkReply();
    void onReadyRead();
    void onSettingsChanged();

private:
    QNetworkAccessManager *m_networkAccessManager;
    Settings *m_settings;
    bool m_busy;
    QByteArray m_buffer;
    QString m_currentResponse;
    QString m_partialLine;
    MarkdownFormatter m_markdownFormatter;

    Q_PROPERTY(bool busy READ busy WRITE setBusy NOTIFY busyChanged)

public:
    bool busy() const;
    void setBusy(bool busy);

signals:
    void busyChanged();
};

#endif // LLM_H
