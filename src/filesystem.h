#ifndef FILESYSTEM_H
#define FILESYSTEM_H

#include <QObject>
#include <QFileSystemModel>

class FileSystem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QFileSystemModel* model READ model CONSTANT)
    Q_PROPERTY(QString rootPath READ rootPath NOTIFY rootPathChanged)
    Q_PROPERTY(QModelIndex currentRootIndex READ currentRootIndex NOTIFY currentRootIndexChanged)
    Q_PROPERTY(QString lastOpenedPath READ lastOpenedPath WRITE setLastOpenedPath NOTIFY lastOpenedPathChanged)

public:
    explicit FileSystem(QObject *parent = nullptr);

    QFileSystemModel* model() const;
    QString rootPath() const;
    QModelIndex currentRootIndex() const;
    QString lastOpenedPath() const;
    void setLastOpenedPath(const QString &path);

public slots:
    void loadFileContent(const QString &filePath);
    void setRootPath(const QString &path);

    Q_INVOKABLE bool isDirectory(const QString &filePath);

signals:
    void fileContentReady(const QString &content);
    void rootPathChanged();
    void currentRootIndexChanged();
    void lastOpenedPathChanged();

private:
    QFileSystemModel* m_model;
    QString m_rootPath;
    QModelIndex m_currentRootIndex;
    QString m_lastOpenedPath;
};

#endif // FILESYSTEM_H
