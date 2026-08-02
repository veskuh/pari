#ifndef GITBLAMEMODEL_H
#define GITBLAMEMODEL_H

#include <QAbstractListModel>
#include <QStringList>
#include <QColor>

struct BlameLine {
    QString hash;
    QString author;
    QString email;
    QString date;
    QString content;
    QColor color;
    bool showMetadata = false;
    int lineNumber = 0;
};

class GitBlameModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum BlameRoles {
        HashRole = Qt::UserRole + 1,
        AuthorRole,
        EmailRole,
        DateRole,
        ContentRole,
        ColorRole,
        ShowMetadataRole,
        LineNumberRole
    };

    explicit GitBlameModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void parseRawOutput(const QString &rawOutput);
    Q_INVOKABLE void clear();

private:
    QList<BlameLine> m_lines;
    QColor getColorForHash(const QString &hash);
    QHash<QString, QColor> m_colorCache;
};

#endif // GITBLAMEMODEL_H
