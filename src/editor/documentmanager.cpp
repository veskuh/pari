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

void DocumentManager::openFile(const QString &filePath, const QString &content)
{
    qDebug() << "DocumentManager::openFile" << filePath;
    if (m_currentIndex != -1 && m_documents[m_currentIndex]->isDirty()) {
        TextDocument *doc = new TextDocument(this);
        doc->setFilePath(filePath);
        m_documents.append(doc);
        setCurrentIndex(m_documents.size() - 1);
    } else {
        if (m_documents.isEmpty()) {
            TextDocument *doc = new TextDocument(this);
            m_documents.append(doc);
            setCurrentIndex(0);
        }
        m_documents[m_currentIndex]->setFilePath(filePath);
    }

    m_documents[m_currentIndex]->setText(content);
    m_documents[m_currentIndex]->setDirty(false);
    emit fileOpened(QUrl::fromLocalFile(filePath), content);
    emit documentsChanged();
}

void DocumentManager::closeFile(int index)
{
    if (index >= 0 && index < m_documents.size()) {
        TextDocument *doc = m_documents.takeAt(index);
        doc->deleteLater();
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
