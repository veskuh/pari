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

bool FileSystem::fileExistsInProject(const QString &filePath)
{
    QString absolutePath = getAbsolutePath(filePath);
    QFile file(absolutePath);
    return file.exists() && absolutePath.startsWith(m_rootPath);
}

QString FileSystem::getAbsolutePath(const QString &filePath)
{
    if (QDir::isAbsolutePath(filePath)) {
        return filePath;
    }
    return QDir::cleanPath(m_rootPath + QDir::separator() + filePath);
}
