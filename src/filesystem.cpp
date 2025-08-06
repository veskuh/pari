#include "filesystem.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QSettings>

FileSystem::FileSystem(QObject *parent)
    : QObject{parent}
    , m_rootPath("")
    , m_currentRootIndex()
{
    m_model = new QFileSystemModel(this);
    m_model->setRootPath(m_rootPath);

    QSettings settings("Pari", "Pari");
    m_lastOpenedPath = settings.value("lastOpenedPath", QDir::homePath()).toString();
}

QFileSystemModel* FileSystem::model() const
{
    return m_model;
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

void FileSystem::loadFileContent(const QString &filePath)
{
    qDebug() << "FileSystem: Attempting to load file:" << filePath;
    QFile file(filePath);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        emit fileContentReady(in.readAll());
        file.close();
        qDebug() << "FileSystem: File loaded successfully.";
    } else {
        qWarning() << "FileSystem: Could not open file:" << filePath << ", Error:" << file.errorString();
    }
}

void FileSystem::setRootPath(const QString &path)
{
    if (m_rootPath != path) {
        m_rootPath = path;
        m_currentRootIndex = m_model->setRootPath(m_rootPath);
        qDebug() << "FileSystem: Setting root path to" << m_rootPath;
        emit rootPathChanged();
        emit currentRootIndexChanged();
        setLastOpenedPath(path); // Save the last opened path
    }
}

bool FileSystem::isDirectory(const QString &filePath)
{
    return m_model->isDir(m_model->index(filePath));
}
