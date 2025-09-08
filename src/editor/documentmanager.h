#ifndef DOCUMENTMANAGER_H
#define DOCUMENTMANAGER_H

#include <QObject>
#include <QList>
#include <QUrl>

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
    void openFile(const QUrl &filePath);
    void closeFile(int index);
    bool saveFile(int index, const QString &content);
    void setCurrentIndex(int index);
    void markDirty(int index);

signals:
    void documentsChanged();
    void currentIndexChanged();
    void fileOpened(const QUrl &filePath, const QString &fileContent);

private:
    QList<TextDocument*> m_documents;
    int m_currentIndex;
};

#endif // DOCUMENTMANAGER_H
