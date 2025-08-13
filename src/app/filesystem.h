#ifndef FILESYSTEM_H
#define FILESYSTEM_H

#include <QObject>
#include <QFileSystemModel>

class Settings;

class FileSystem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QFileSystemModel* model READ model CONSTANT)
    Q_PROPERTY(QString rootPath READ rootPath NOTIFY rootPathChanged)
    Q_PROPERTY(QModelIndex currentRootIndex READ currentRootIndex NOTIFY currentRootIndexChanged)
    Q_PROPERTY(QString lastOpenedPath READ lastOpenedPath WRITE setLastOpenedPath NOTIFY lastOpenedPathChanged)
    Q_PROPERTY(QString currentFilePath READ currentFilePath WRITE setCurrentFilePath NOTIFY currentFilePathChanged)
    Q_PROPERTY(QString homePath READ homePath CONSTANT)

public:
    explicit FileSystem(Settings *settings, QObject *parent = nullptr);

    QFileSystemModel* model() const;
    QString rootPath() const;
    QModelIndex currentRootIndex() const;
    QString lastOpenedPath() const;
    void setLastOpenedPath(const QString &path);
    QString currentFilePath() const;
    void setCurrentFilePath(const QString &path);
    QString homePath() const;

public slots:
    void loadFileContent(const QString &filePath);
    void setRootPath(const QString &path);
    void saveFile(const QString &filePath, const QString &content);

    Q_INVOKABLE bool isDirectory(const QString &filePath);

signals:
    void fileContentReady(const QString &filePath, const QString &content);
    void rootPathChanged();
    void currentRootIndexChanged();
    void lastOpenedPathChanged();
    void currentFilePathChanged();
    void fileSaved(const QString &filePath);

private:
    QFileSystemModel* m_model;
    QString m_rootPath;
    QModelIndex m_currentRootIndex;
    QString m_lastOpenedPath;
    QString m_currentFilePath;
    QString m_homePath;
    Settings* m_settings;
};

#endif // FILESYSTEM_H
