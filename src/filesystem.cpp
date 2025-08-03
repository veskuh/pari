#include "filesystem.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>

FileSystem::FileSystem(QObject *parent)
    : QObject{parent}
    , m_rootPath("")
    , m_currentRootIndex()
{
    m_model = new QFileSystemModel(this);
    m_model->setRootPath(m_rootPath);
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
    }
}

bool FileSystem::isDirectory(const QString &filePath)
{
    return m_model->isDir(m_model->index(filePath));
}
