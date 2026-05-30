#include "textdocument.h"
#include <QFileInfo>

TextDocument::TextDocument(QObject *parent) : QObject(parent), m_isDirty(false)
{
}

QString TextDocument::filePath() const
{
    return m_filePath;
}

void TextDocument::setFilePath(const QString &filePath)
{
    if (m_filePath != filePath) {
        m_filePath = filePath;
        m_fileName = QFileInfo(m_filePath).fileName();
        emit filePathChanged();
        emit fileNameChanged();
    }
}

QString TextDocument::fileName() const
{
    return m_fileName;
}

QString TextDocument::text() const
{
    return m_text;
}

void TextDocument::setText(const QString &text)
{
    if (m_text != text) {
        m_text = text;
        emit textChanged();
    }
}

bool TextDocument::isDirty() const
{
    return m_isDirty;
}

void TextDocument::setDirty(bool isDirty)
{
    if (m_isDirty != isDirty) {
        m_isDirty = isDirty;
        emit dirtyChanged();
    }
}

QDateTime TextDocument::lastModified() const
{
    return m_lastModified;
}

void TextDocument::setLastModified(const QDateTime &lastModified)
{
    if (m_lastModified != lastModified) {
        m_lastModified = lastModified;
        emit lastModifiedChanged();
    }
}

bool TextDocument::pendingReloadPrompt() const
{
    return m_pendingReloadPrompt;
}

void TextDocument::setPendingReloadPrompt(bool pending)
{
    if (m_pendingReloadPrompt != pending) {
        m_pendingReloadPrompt = pending;
        emit pendingReloadPromptChanged();
    }
}
