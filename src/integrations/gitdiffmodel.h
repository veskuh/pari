#ifndef GITDIFFMODEL_H
#define GITDIFFMODEL_H

#include <QAbstractListModel>
#include <QStringList>

struct GitDiffLine {
    enum Type {
        Context = 0,
        Addition,
        Deletion,
        FileHeader,
        HunkHeader,
        UntrackedFile,
        StatusFile
    };

    Type type;
    QString content;
    int oldLineNumber;
    int newLineNumber;
    QString filePath;
};

class GitDiffModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int resultCount READ rowCount NOTIFY countChanged)

public:
    enum GitDiffRoles {
        TypeRole = Qt::UserRole + 1,
        ContentRole,
        OldLineRole,
        NewLineRole,
        FilePathRole
    };

    explicit GitDiffModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    Q_INVOKABLE void parseRawDiff(const QString &rawDiff);
    Q_INVOKABLE void clear();

signals:
    void countChanged();

protected:
    QHash<int, QByteArray> roleNames() const override;

private:
    QList<GitDiffLine> m_lines;
};

#endif // GITDIFFMODEL_H
