#include "filesystem.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QSettings>

FileSystem::FileSystem(QObject *parent)
    : QObject{parent}
    , m_rootPath("")
    , m_currentRootIndex()
    , m_currentFilePath("")
{
    m_model = new QFileSystemModel(this);
    m_model->setRootPath(m_rootPath);
    m_model->setFilter(QDir::AllDirs | QDir::Files | QDir::NoDotAndDotDot);

    m_proxyModel = new FileTreeProxyModel(this);
    m_proxyModel->setSourceModel(m_model);
    m_proxyModel->setFilterCaseSensitivity(Qt::CaseInsensitive);
    m_proxyModel->setFilterKeyColumn(0);
    m_proxyModel->setRecursiveFilteringEnabled(true);

    QSettings settings("Pari", "Pari");
    m_lastOpenedPath = settings.value("lastOpenedPath", QDir::homePath()).toString();
    m_homePath = QDir::homePath();
}

QObject* FileSystem::model() const
{
    return m_proxyModel;
}

QString FileSystem::rootPath() const
{
    return m_rootPath;
}

QModelIndex FileSystem::currentRootIndex() const
{
    return m_currentRootIndex;
}

QString FileSystem::lastOpenedPath() const
{
    return m_lastOpenedPath;
}

void FileSystem::setLastOpenedPath(const QString &path)
{
    if (m_lastOpenedPath != path) {
        m_lastOpenedPath = path;
        QSettings settings("Pari", "Pari");
        settings.setValue("lastOpenedPath", m_lastOpenedPath);
        emit lastOpenedPathChanged();
    }
}

QString FileSystem::currentFilePath() const
{
    return m_currentFilePath;
}

void FileSystem::setCurrentFilePath(const QString &path)
{
    if (m_currentFilePath != path) {
        m_currentFilePath = path;
        emit currentFilePathChanged();
    }
}

void FileSystem::loadFileContent(const QString &filePath)
{
    QFile file(filePath);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        emit fileContentReady(filePath, in.readAll());
        file.close();
        setCurrentFilePath(filePath);
    } else {
        qWarning() << "FileSystem: Could not open file:" << filePath << ", Error:" << file.errorString();
    }
}

void FileSystem::saveFile(const QString &filePath, const QString &content)
{
    QFile file(filePath);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream out(&file);
        out << content;
        file.close();
        setCurrentFilePath(filePath);
        emit fileSaved(filePath);
    } else {
        qWarning() << "Could not save file:" << file.errorString();
    }
}

void FileSystem::setRootPath(const QString &path)
{
    if (m_rootPath != path) {
        m_rootPath = path;
        m_currentRootIndex = m_model->setRootPath(m_rootPath);
        emit rootPathChanged();
        emit currentRootIndexChanged();
        setLastOpenedPath(path); // Save the last opened path
    }
}

bool FileSystem::isDirectory(const QString &filePath)
{
    return m_model->isDir(m_model->index(filePath));
}

QString FileSystem::homePath() const
{
    return m_homePath;
}

void FileSystem::setFilter(const QString &filter)
{
    m_proxyModel->setFilterRegularExpression(filter);
}

QModelIndex FileSystem::mapToProxy(const QModelIndex &sourceIndex)
{
    return m_proxyModel->mapFromSource(sourceIndex);
}
