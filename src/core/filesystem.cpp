#include "filesystem.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QSettings>

FileSystem::FileSystem(QObject *parent)
    : QObject{parent}
    , m_rootPath("")
    , m_currentRootIndex()
    , m_isGitRepository(false)
{
    m_model = new QFileSystemModel(this);
    m_model->setRootPath(m_rootPath);

    QSettings settings("Pari", "Pari");
    m_lastOpenedPath = settings.value("lastOpenedPath", QDir::homePath()).toString();
    m_homePath = QDir::homePath();
}

QFileSystemModel* FileSystem::model() const
{
    return m_model;
}

QString FileSystem::rootPath() const
{
    return m_rootPath;
}

QString FileSystem::rootName() const { 
    QDir dir(m_rootPath); 
    return dir.dirName(); 
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

#include <QDir>

void FileSystem::setRootPath(const QString &path)
{
    if (m_rootPath != path) {
        m_rootPath = path;
        m_currentRootIndex = m_model->setRootPath(m_rootPath);
        emit rootPathChanged();
        emit rootNameChanged();
        emit currentRootIndexChanged();
        setLastOpenedPath(path); // Save the last opened path

        QDir dir(path);
        bool isGit = dir.exists(".git");
        if (m_isGitRepository != isGit) {
            m_isGitRepository = isGit;
            emit isGitRepositoryChanged();
        }

        emit projectOpened(path);
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

bool FileSystem::isGitRepository() const
{
    return m_isGitRepository;
}
