#include "lsploghandler.h"

LspLogHandler::LspLogHandler(QObject *parent) : QObject(parent)
{
}

void LspLogHandler::addMessage(const QString &message)
{
    m_logMessages.append(message);
    emit logMessagesChanged();
}

QStringList LspLogHandler::logMessages() const
{
    return m_logMessages;
}
