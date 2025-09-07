#ifndef EDITORMANAGER_H
#define EDITORMANAGER_H

#include <QObject>
#include <QList>
#include <QString>

class Document : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString filePath READ filePath WRITE setFilePath NOTIFY filePathChanged)
    Q_PROPERTY(QString content READ content WRITE setContent NOTIFY contentChanged)
    Q_PROPERTY(bool dirty READ isDirty WRITE setDirty NOTIFY dirtyChanged)

public:
    explicit Document(QObject *parent = nullptr);

    QString filePath() const;
    void setFilePath(const QString &filePath);

    QString content() const;
    void setContent(const QString &content);

    bool isDirty() const;
    void setDirty(bool dirty);

signals:
    void filePathChanged();
    void contentChanged();
    void dirtyChanged();

private:
    QString m_filePath;
    QString m_content;
    bool m_dirty;
};

class EditorManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QList<QObject*> openDocuments READ openDocuments NOTIFY openDocumentsChanged)
    Q_PROPERTY(int activeDocumentIndex READ activeDocumentIndex WRITE setActiveDocumentIndex NOTIFY activeDocumentIndexChanged)

public:
    explicit EditorManager(QObject *parent = nullptr);

    QList<QObject*> openDocuments() const;
    int activeDocumentIndex() const;
    void setActiveDocumentIndex(int index);

public slots:
    void openFile(const QString &filePath);
    void closeFile(int index);
    void saveFile(int index, const QString &content);
    void documentContentChanged(int index, const QString &content);

signals:
    void openDocumentsChanged();
    void activeDocumentIndexChanged();
    void fileOpened(const QString &filePath, const QString &content);

private:
    QList<Document*> m_openDocuments;
    int m_activeDocumentIndex;
};

#endif // EDITORMANAGER_H
