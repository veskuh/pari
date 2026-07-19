#ifndef FILESYSTEM_H
#define FILESYSTEM_H

#include <QObject>
#include <QFileSystemModel>
#include <QSortFilterProxyModel>

class ProjectTreeProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
public:
    using QSortFilterProxyModel::QSortFilterProxyModel;

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;
};

class FileSystem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QAbstractItemModel* model READ model CONSTANT)
    Q_PROPERTY(QString rootPath READ rootPath NOTIFY rootPathChanged)
    Q_PROPERTY(QString rootName READ rootName NOTIFY rootNameChanged)
    Q_PROPERTY(QModelIndex currentRootIndex READ currentRootIndex NOTIFY currentRootIndexChanged)
    Q_PROPERTY(QString lastOpenedPath READ lastOpenedPath WRITE setLastOpenedPath NOTIFY lastOpenedPathChanged)
    Q_PROPERTY(QString currentFilePath READ currentFilePath WRITE setCurrentFilePath NOTIFY currentFilePathChanged)
    Q_PROPERTY(QString homePath READ homePath CONSTANT)
    Q_PROPERTY(bool isGitRepository READ isGitRepository NOTIFY isGitRepositoryChanged)
    Q_PROPERTY(bool showHiddenFiles READ showHiddenFiles WRITE setShowHiddenFiles NOTIFY showHiddenFilesChanged)

public:
    explicit FileSystem(QObject *parent = nullptr);

    QAbstractItemModel* model() const;
    QString rootPath() const;
    QString rootName() const;
    QModelIndex currentRootIndex() const;
    QString lastOpenedPath() const;
    void setLastOpenedPath(const QString &path);
    QString currentFilePath() const;
    void setCurrentFilePath(const QString &path);
    QString homePath() const;
    bool isGitRepository() const;
    bool showHiddenFiles() const;
    void setShowHiddenFiles(bool show);

public slots:
    void loadFileContent(const QString &filePath);
    void setRootPath(const QString &path);
    void saveFile(const QString &filePath, const QString &content);

    Q_INVOKABLE bool isDirectory(const QString &filePath);
    Q_INVOKABLE bool fileExistsInProject(const QString &filePath);
    Q_INVOKABLE QString getAbsolutePath(const QString &filePath);
    Q_INVOKABLE QVariantMap getFileInfo(const QString &filePath);
    Q_INVOKABLE bool renameFile(const QString &oldPath, const QString &newPath);
    Q_INVOKABLE bool createNewFile(const QString &folderPath, const QString &fileName);

signals:
    void fileContentReady(const QString &filePath, const QString &content);
    void rootPathChanged();
    void rootNameChanged();
    void currentRootIndexChanged();
    void lastOpenedPathChanged();
    void currentFilePathChanged();
    void fileSaved(const QString &filePath);
    void isGitRepositoryChanged();
    void projectOpened(const QString &path);
    void fileRenamed(const QString &oldPath, const QString &newPath);
    void showHiddenFilesChanged();

private:
    QFileSystemModel* m_model;
    ProjectTreeProxyModel* m_proxy;
    QString m_rootPath;
    QString m_lastOpenedPath;
    QString m_currentFilePath;
    QString m_homePath;
    bool m_isGitRepository;
    bool m_showHiddenFiles;
};

#endif // FILESYSTEM_H
