#ifndef LSPLOGHANDLER_H
#define LSPLOGHANDLER_H

#include <QObject>
#include <QStringList>

class LspLogHandler : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList logMessages READ logMessages NOTIFY logMessagesChanged)

public:
    explicit LspLogHandler(QObject *parent = nullptr);

    Q_INVOKABLE void addMessage(const QString &message);
    QStringList logMessages() const;

signals:
    void logMessagesChanged();

private:
    QStringList m_logMessages;
};

#endif // LSPLOGHANDLER_H
