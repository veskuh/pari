#ifndef TEXTDOCUMENT_H
#define TEXTDOCUMENT_H

#include <QObject>
#include <QString>

class TextDocument : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString filePath READ filePath WRITE setFilePath NOTIFY filePathChanged)
    Q_PROPERTY(QString fileName READ fileName NOTIFY fileNameChanged)
    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)
    Q_PROPERTY(bool isDirty READ isDirty WRITE setDirty NOTIFY dirtyChanged)

public:
    explicit TextDocument(QObject *parent = nullptr);

    QString filePath() const;
    void setFilePath(const QString &filePath);

    QString fileName() const;

    QString text() const;
    void setText(const QString &text);

    bool isDirty() const;
    void setDirty(bool isDirty);

signals:
    void filePathChanged();
    void fileNameChanged();
    void textChanged();
    void dirtyChanged();

private:
    QString m_filePath;
    QString m_fileName;
    QString m_text;
    bool m_isDirty;
};

#endif // TEXTDOCUMENT_H
