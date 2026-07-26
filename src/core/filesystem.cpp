#include "filesystem.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QSettings>

bool ProjectTreeProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    const QAbstractItemModel *src = sourceModel();
    if (!src)
        return true;
    QModelIndex index = src->index(sourceRow, 0, sourceParent);
    if (!index.isValid())
        return true;

    const QString fileName = index.data(QFileSystemModel::FileNameRole).toString();
    if (fileName == QLatin1String(".git") ||
        fileName == QLatin1String(".svn") ||
        fileName == QLatin1String(".hg")) {
        return false;
    }
    return true;
}

void ProjectTreeProxyModel::setSourceModel(QAbstractItemModel *sourceModel)
{
    QSortFilterProxyModel::setSourceModel(sourceModel);
    if (!sourceModel)
        return;

    // QFileSystemModel emits layoutChanged when its background sort finishes,
    // right after rowsInserted. QQuickTreeView cannot handle layoutChanged —
    // it leaves stale delegate instances on screen (the duplicate-rows bug).
    //
    // Fix: fully disconnect the source's layout signals so the proxy neither
    // processes nor forwards them. rowsInserted/rowsRemoved/dataChanged still
    // flow through, so the tree stays correct; the rootIndex and the view's
    // expansion state are preserved. (QFileSystemModel inserts rows in sorted
    // order, so suppressing the follow-up layoutChanged doesn't change order.)
    disconnect(sourceModel, &QAbstractItemModel::layoutAboutToBeChanged, this, nullptr);
    disconnect(sourceModel, &QAbstractItemModel::layoutChanged, this, nullptr);
}

bool FileSystem::renameFile(const QString &oldPath, const QString &newPath)
{
    QFile file(oldPath);
    if (file.rename(newPath)) {
        emit fileRenamed(oldPath, newPath);
        return true;
    }
    return false;
}

bool FileSystem::createNewFile(const QString &folderPath, const QString &fileName)
{
    QDir dir(folderPath);
    if (!dir.exists()) {
        return false;
    }

    QString filePath = dir.absoluteFilePath(fileName);
    if (QFile::exists(filePath)) {
        return false;
    }

    QFile file(filePath);
    if (file.open(QIODevice::WriteOnly)) {
        file.close();
        // Notify UI that a new empty file is ready
        emit fileContentReady(filePath, "");
        setCurrentFilePath(filePath);
        return true;
    }
    return false;
}

FileSystem::FileSystem(QObject *parent)
    : QObject{parent}
    , m_rootPath("")
    , m_currentFilePath("")
    , m_isGitRepository(false)
    , m_showHiddenFiles(false)
{
    m_model = new QFileSystemModel(this);
    m_model->setFilter(QDir::AllDirs | QDir::Files | QDir::NoDotAndDotDot);
    m_model->setRootPath(m_rootPath);

    m_proxy = new ProjectTreeProxyModel(this);
    m_proxy->setSourceModel(m_model);

    QSettings settings("Pari", "Pari");
    m_lastOpenedPath = settings.value("lastOpenedPath", QDir::homePath()).toString();
    m_homePath = QDir::homePath();
}

QAbstractItemModel* FileSystem::model() const
{
    return m_proxy;
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
    return m_proxy->mapFromSource(m_model->index(m_rootPath));
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
        m_model->setRootPath(m_rootPath);
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

bool FileSystem::showHiddenFiles() const
{
    return m_showHiddenFiles;
}

void FileSystem::setShowHiddenFiles(bool show)
{
    if (m_showHiddenFiles != show) {
        m_showHiddenFiles = show;
        QDir::Filters filter = QDir::AllDirs | QDir::Files | QDir::NoDotAndDotDot;
        if (m_showHiddenFiles) {
            filter |= QDir::Hidden;
        }
        m_model->setFilter(filter);
        emit showHiddenFilesChanged();
    }
}

bool FileSystem::fileExistsInProject(const QString &filePath)
{
    QString absolutePath = getAbsolutePath(filePath);
    QFile file(absolutePath);
    return file.exists() && QFileInfo(absolutePath).isFile() && absolutePath.startsWith(m_rootPath);
}

QString FileSystem::getAbsolutePath(const QString &filePath)
{   
    if (QDir::isAbsolutePath(filePath)) {
        return filePath;
    }
    return QDir::cleanPath(m_rootPath + QDir::separator() + filePath);
}

QVariantMap FileSystem::getFileInfo(const QString &filePath)
{
    QFileInfo fileInfo(filePath);
    QVariantMap info;
    info.insert("name", fileInfo.fileName());
    info.insert("path", fileInfo.absoluteFilePath());
    info.insert("size", fileInfo.size());
    info.insert("modified", fileInfo.lastModified().toString());
    return info;
}
