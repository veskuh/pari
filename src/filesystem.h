#ifndef FILESYSTEM_H
#define FILESYSTEM_H

#include <QObject>
#include <QFileSystemModel>

class FileSystem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QFileSystemModel* model READ model CONSTANT)

public:
    explicit FileSystem(QObject *parent = nullptr);

    QFileSystemModel* model() const;

public slots:
    void loadFileContent(const QString &filePath);

    Q_INVOKABLE bool isDirectory(const QString &filePath);

signals:
    void fileContentReady(const QString &content);

private:
    QFileSystemModel* m_model;
};

#endif // FILESYSTEM_H
