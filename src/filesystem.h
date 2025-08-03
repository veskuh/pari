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

public:
    explicit FileSystem(QObject *parent = nullptr);

    QFileSystemModel* model() const;
    QString rootPath() const;
    QModelIndex currentRootIndex() const;

public slots:
    void loadFileContent(const QString &filePath);
    void setRootPath(const QString &path);

    Q_INVOKABLE bool isDirectory(const QString &filePath);

signals:
    void fileContentReady(const QString &content);
    void rootPathChanged();
    void currentRootIndexChanged();

private:
    QFileSystemModel* m_model;
    QString m_rootPath;
    QModelIndex m_currentRootIndex;
};

#endif // FILESYSTEM_H
