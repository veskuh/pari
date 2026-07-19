#include "documentmanager.h"
#include "textdocument.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QFileInfo>
#include <QTimer>

DocumentManager::DocumentManager(QObject *parent) : QObject(parent), m_currentIndex(-1)
{
    m_watcher = new QFileSystemWatcher(this);
    connect(m_watcher, &QFileSystemWatcher::fileChanged, this, &DocumentManager::onFileChanged);
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
    for (int i = 0; i < m_documents.size(); ++i) {
        if (m_documents[i]->filePath() == filePath) {
            setCurrentIndex(i);
            emit fileOpened(QUrl::fromLocalFile(filePath), m_documents[i]->text());
            return;
        }
    }

    QFile file(filePath);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        QString content(in.readAll());
        file.close();

        TextDocument *doc = new TextDocument(this);
        doc->setFilePath(filePath);
        doc->setText(content);
        doc->setDirty(false);
        doc->setLastModified(QFileInfo(filePath).lastModified());

        connect(doc, &TextDocument::dirtyChanged, this, &DocumentManager::dirtyStatusChanged);

        if (newTab || m_documents.isEmpty() || m_currentIndex == -1 || (m_currentIndex != -1 && m_documents[m_currentIndex]->isDirty())) {
            m_documents.append(doc);
            setCurrentIndex(m_documents.size() - 1);
        } else {
            TextDocument *oldDoc = m_documents[m_currentIndex];
            if (oldDoc) {
                m_watcher->removePath(oldDoc->filePath());
                stopReloadTimer(oldDoc->filePath());
            }
            m_documents[m_currentIndex] = doc;
            if (oldDoc) {
                oldDoc->deleteLater();
            }
        }
        m_watcher->addPath(filePath);
        emit documentsChanged();
        emit fileOpened(QUrl::fromLocalFile(filePath), content);
        emit currentIndexChanged();
        emit dirtyStatusChanged();

    } else {
        qWarning() << "DocumentManager: Could not open file:" << filePath << ", Error:" << file.errorString();
    }
}

void DocumentManager::closeFile(int index)
{
    if (index >= 0 && index < m_documents.size()) {
        TextDocument *doc = m_documents.takeAt(index);
        m_watcher->removePath(doc->filePath());
        stopReloadTimer(doc->filePath());
        doc->deleteLater();
        emit documentsChanged();
        emit dirtyStatusChanged();

        if (m_documents.isEmpty()) {
            setCurrentIndex(-1);
        } else {
            if (m_currentIndex > index) {
                setCurrentIndex(m_currentIndex - 1);
            } else if (m_currentIndex == index) {
                if (m_currentIndex >= m_documents.size()) {
                    setCurrentIndex(m_documents.size() - 1);
                } else {
                    emit currentIndexChanged();
                }
            } else {
                emit currentIndexChanged();
            }
        }
    }
}

bool DocumentManager::saveFile(int index, const QString &content)
{
    if (index >= 0 && index < m_documents.size()) {
        TextDocument *doc = m_documents[index];
        QString path = doc->filePath();
        m_watcher->removePath(path);
        
        QFile file(path);
        if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            QTextStream out(&file);
            out << content;
            file.close();
            doc->setText(content);
            doc->setDirty(false);
            doc->setLastModified(QFileInfo(path).lastModified());
            emit dirtyStatusChanged();
            
            m_watcher->addPath(path);
            return true;
        }
        m_watcher->addPath(path);
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
        emit dirtyStatusChanged();
    }
}

void DocumentManager::updatePath(const QString &oldPath, const QString &newPath)
{
    for (TextDocument *doc : m_documents) {
        if (doc->filePath() == oldPath) {
            m_watcher->removePath(oldPath);
            stopReloadTimer(oldPath);
            doc->setFilePath(newPath);
            doc->setLastModified(QFileInfo(newPath).lastModified());
            m_watcher->addPath(newPath);
            emit documentsChanged();
            return;
        }
    }
}

bool DocumentManager::isDirty(const QString &filePath) const
{
    for (TextDocument *doc : m_documents) {
        if (doc->filePath() == filePath) {
            return doc->isDirty();
        }
    }
    return false;
}

void DocumentManager::onFileChanged(const QString &path)
{
    bool hasDoc = false;
    for (const TextDocument *doc : m_documents) {
        if (doc->filePath() == path) {
            hasDoc = true;
            break;
        }
    }
    if (!hasDoc) return;

    scheduleReloadCheck(path);
}

void DocumentManager::scheduleReloadCheck(const QString &path)
{
    auto it = m_reloadTimers.constFind(path);
    if (it != m_reloadTimers.constEnd()) {
        it.value()->start();
        return;
    }
    QTimer *timer = new QTimer(this);
    timer->setSingleShot(true);
    timer->setInterval(200);
    connect(timer, &QTimer::timeout, this, [this, path]() { onReloadCheckTimeout(path); });
    m_reloadTimers.insert(path, timer);
    timer->start();
}

void DocumentManager::stopReloadTimer(const QString &path)
{
    auto it = m_reloadTimers.find(path);
    if (it != m_reloadTimers.end()) {
        it.value()->stop();
        it.value()->deleteLater();
        m_reloadTimers.erase(it);
    }
}

void DocumentManager::onReloadCheckTimeout(const QString &path)
{
    TextDocument *targetDoc = nullptr;
    int targetIndex = -1;
    for (int i = 0; i < m_documents.size(); ++i) {
        if (m_documents[i]->filePath() == path) {
            targetDoc = m_documents[i];
            targetIndex = i;
            break;
        }
    }

    if (!targetDoc) return;

    QFileInfo info(path);
    if (!info.exists()) {
        return;
    }

    QDateTime diskTime = info.lastModified();
    if (diskTime <= targetDoc->lastModified()) {
        return;
    }

    if (!targetDoc->isDirty()) {
        reloadFile(path);
    } else {
        if (targetDoc->pendingReloadPrompt())
            return;
        targetDoc->setPendingReloadPrompt(true);
        if (targetIndex == m_currentIndex) {
            emit fileModifiedExternally(path);
        }
    }
}

void DocumentManager::reloadFile(const QString &filePath)
{
    TextDocument *doc = nullptr;
    for (TextDocument *d : m_documents) {
        if (d->filePath() == filePath) {
            doc = d;
            break;
        }
    }

    if (!doc) return;

    QFile file(filePath);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        QString content = in.readAll();
        file.close();

        doc->setText(content);
        doc->setDirty(false);
        doc->setLastModified(QFileInfo(filePath).lastModified());
        doc->setPendingReloadPrompt(false);
        emit dirtyStatusChanged();
        emit fileContentReloaded(filePath, content);
        
        m_watcher->addPath(filePath);
    }
}

void DocumentManager::ignoreExternalChange(const QString &filePath)
{
    TextDocument *doc = nullptr;
    for (TextDocument *d : m_documents) {
        if (d->filePath() == filePath) {
            doc = d;
            break;
        }
    }

    if (doc) {
        doc->setLastModified(QFileInfo(filePath).lastModified());
        doc->setPendingReloadPrompt(false);
    }
}
