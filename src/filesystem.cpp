#include "filesystem.h"
#include <QFile>
#include <QTextStream>

FileSystem::FileSystem(QObject *parent)
    : QObject{parent}
{
    m_model = new QFileSystemModel(this);
    m_model->setRootPath("");
}

QFileSystemModel* FileSystem::model() const
{
    return m_model;
}

void FileSystem::loadFileContent(const QString &filePath)
{
    QFile file(filePath);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        emit fileContentReady(in.readAll());
        file.close();
    }
}

bool FileSystem::isDirectory(const QString &filePath)
{
    return m_model->isDir(m_model->index(filePath));
}
