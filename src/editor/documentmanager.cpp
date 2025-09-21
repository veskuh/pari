#include "documentmanager.h"
#include "textdocument.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>

DocumentManager::DocumentManager(QObject *parent) : QObject(parent), m_currentIndex(-1)
{
}

QList<QObject*> DocumentManager::documents() const
{
    QList<QObject*> docs;
    for (TextDocument *doc : m_documents) {
        docs.append(doc);
    }
    return docs;
}

int DocumentManager::currentIndex() const
{
    return m_currentIndex;
}

void DocumentManager::openFile(const QString &filePath, bool newTab)
{
    QFile file(filePath);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        QString content(in.readAll());
        file.close();

        for (int i = 0; i < m_documents.size(); ++i) {
            if (m_documents[i]->filePath() == filePath) {
                setCurrentIndex(i);
                return;
            }
        }

        TextDocument *doc = new TextDocument(this);
        doc->setFilePath(filePath);
        doc->setText(content);
        doc->setDirty(false);

        if (newTab || m_documents.isEmpty() || m_currentIndex == -1 || (m_currentIndex !=-1 && m_documents[m_currentIndex]->isDirty())) {
            m_documents.append(doc);
            setCurrentIndex(m_documents.size() - 1);
        } else {
            m_documents[m_currentIndex] = doc;
            emit fileOpened(QUrl::fromLocalFile(filePath), content);
            emit documentsChanged();
        }
        emit fileOpened(QUrl::fromLocalFile(filePath), doc->text());
        emit documentsChanged();

    } else {
        qWarning() << "DocumentManager: Could not open file:" << filePath << ", Error:" << file.errorString();
    }
}

void DocumentManager::closeFile(int index)
{
    if (index >= 0 && index < m_documents.size()) {
        TextDocument *doc = m_documents.takeAt(index);
        doc->deleteLater();

        if (m_documents.isEmpty()) {
            setCurrentIndex(-1);
        } else {
            if (m_currentIndex >= index) {
                setCurrentIndex(m_currentIndex - 1);
            }
        }
        emit documentsChanged();
    }
}

bool DocumentManager::saveFile(int index, const QString &content)
{
    if (index >= 0 && index < m_documents.size()) {
        TextDocument *doc = m_documents[index];
        QFile file(doc->filePath());
        if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            QTextStream out(&file);
            out << content;
            file.close();
            doc->setDirty(false);
            return true;
        }
    }
    return false;
}

void DocumentManager::setCurrentIndex(int index)
{
    if (m_currentIndex != index) {
        m_currentIndex = index;
        emit currentIndexChanged();
    }
}

void DocumentManager::markDirty(int index)
{
    if (index >= 0 && index < m_documents.size()) {
        m_documents[index]->setDirty(true);
    }
}
