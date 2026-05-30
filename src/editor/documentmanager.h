#ifndef DOCUMENTMANAGER_H
#define DOCUMENTMANAGER_H

#include <QObject>
#include <QList>
#include <QUrl>
#include <QFileSystemWatcher>
#include <QDateTime>

class TextDocument;

class DocumentManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QList<QObject*> documents READ documents NOTIFY documentsChanged)
    Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged)

public:
    explicit DocumentManager(QObject *parent = nullptr);

    QList<QObject*> documents() const;
    int currentIndex() const;

public slots:
    void openFile(const QString &filePath, bool newTab = false);
    void closeFile(int index);
    bool saveFile(int index, const QString &content);
    void setCurrentIndex(int index);
    void markDirty(int index);
    void updatePath(const QString &oldPath, const QString &newPath);
    Q_INVOKABLE bool isDirty(const QString &filePath) const;
    Q_INVOKABLE void reloadFile(const QString &filePath);
    Q_INVOKABLE void ignoreExternalChange(const QString &filePath);

signals:
    void documentsChanged();
    void currentIndexChanged();
    void dirtyStatusChanged();
    void fileOpened(const QUrl &filePath, const QString &content);
    void fileContentReloaded(const QString &filePath, const QString &content);
    void fileModifiedExternally(const QString &filePath);

private slots:
    void onFileChanged(const QString &path);

private:
    QList<TextDocument*> m_documents;
    int m_currentIndex;
    QFileSystemWatcher *m_watcher;
};

#endif // DOCUMENTMANAGER_H
