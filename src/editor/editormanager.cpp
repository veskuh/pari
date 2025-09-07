#include "editormanager.h"
#include <QFile>
#include <QMessageBox>
#include <QTextStream>
#include <QDebug>

Document::Document(QObject *parent)
    : QObject(parent), m_dirty(false)
{
}

QString Document::filePath() const
{
    return m_filePath;
}

void Document::setFilePath(const QString &filePath)
{
    if (m_filePath != filePath) {
        m_filePath = filePath;
        emit filePathChanged();
    }
}

QString Document::content() const
{
    return m_content;
}

void Document::setContent(const QString &content)
{
    if (m_content != content) {
        m_content = content;
        emit contentChanged();
    }
}

bool Document::isDirty() const
{
    return m_dirty;
}

void Document::setDirty(bool dirty)
{
    if (m_dirty != dirty) {
        m_dirty = dirty;
        emit dirtyChanged();
    }
}

EditorManager::EditorManager(QObject *parent)
    : QObject(parent), m_activeDocumentIndex(-1)
{
}

QList<QObject*> EditorManager::openDocuments() const
{
    QList<QObject*> list;
    for (Document* doc : m_openDocuments) {
        list.append(doc);
    }
    return list;
}

int EditorManager::activeDocumentIndex() const
{
    return m_activeDocumentIndex;
}

void EditorManager::setActiveDocumentIndex(int index)
{
    if (m_activeDocumentIndex != index) {
        m_activeDocumentIndex = index;
        emit activeDocumentIndexChanged();
    }
}

void EditorManager::openFile(const QString &filePath)
{
    for (int i = 0; i < m_openDocuments.size(); ++i) {
        if (m_openDocuments[i]->filePath() == filePath) {
            setActiveDocumentIndex(i);
            return;
        }
    }

    QFile file(filePath);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        QString content = in.readAll();
        file.close();

        Document *doc = new Document(this);
        doc->setFilePath(filePath);
        doc->setContent(content);
        doc->setDirty(false);

        m_openDocuments.append(doc);
        emit openDocumentsChanged();
        setActiveDocumentIndex(m_openDocuments.size() - 1);
        emit fileOpened(filePath, content);
    } else {
        qWarning() << "EditorManager: Could not open file:" << filePath << ", Error:" << file.errorString();
    }
}

void EditorManager::closeFile(int index)
{
    if (index >= 0 && index < m_openDocuments.size()) {
        Document *doc = m_openDocuments[index];
        if (doc->isDirty()) {
            QMessageBox::StandardButton reply;
            reply = QMessageBox::question(nullptr, "Save Changes?",
                                          "The document has been modified. Do you want to save your changes?",
                                          QMessageBox::Save | QMessageBox::Discard | QMessageBox::Cancel);
            if (reply == QMessageBox::Save) {
                saveFile(index, doc->content());
            } else if (reply == QMessageBox::Cancel) {
                return;
            }
        }

        Document* docToDelete = m_openDocuments.takeAt(index);
        delete docToDelete;
        emit openDocumentsChanged();

        if (m_openDocuments.isEmpty()) {
            setActiveDocumentIndex(-1);
        } else if (m_activeDocumentIndex >= index) {
            setActiveDocumentIndex(qMax(0, m_activeDocumentIndex - 1));
        }
    }
}

void EditorManager::saveFile(int index, const QString &content)
{
    if (index >= 0 && index < m_openDocuments.size()) {
        Document *doc = m_openDocuments[index];
        QFile file(doc->filePath());
        if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            QTextStream out(&file);
            out << content;
            file.close();
            doc->setContent(content);
            doc->setDirty(false);
        } else {
            qWarning() << "Could not save file:" << file.errorString();
        }
    }
}

void EditorManager::documentContentChanged(int index, const QString &content)
{
    if (index >= 0 && index < m_openDocuments.size()) {
        Document *doc = m_openDocuments[index];
        if (doc->content() != content) {
            doc->setContent(content);
            doc->setDirty(true);
        }
    }
}
