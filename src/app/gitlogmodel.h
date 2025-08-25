#ifndef GITLOGMODEL_H
#define GITLOGMODEL_H

#include <QAbstractListModel>
#include <QStringList>
#include <QDateTime>

struct GitCommit {
    QString sha;
    QString authorName;
    QString authorEmail;
    QDateTime authorDate;
    QString messageHeader;
    QString messageBody;
};

class GitLogModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum GitLogRoles {
        ShaRole = Qt::UserRole + 1,
        AuthorNameRole,
        AuthorEmailRole,
        DateRole,
        TimeRole,
        MessageHeaderRole,
        MessageBodyRole
    };

    explicit GitLogModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    Q_INVOKABLE void parseAndSetLog(const QString &log);

protected:
    QHash<int, QByteArray> roleNames() const override;

private:
    QList<GitCommit> m_commits;
};

#endif // GITLOGMODEL_H
