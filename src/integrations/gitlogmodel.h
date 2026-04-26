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
    QString date;
    QString time;
    QString messageHeader;
    QString messageBody;
    QString details; // The "Refactoring Dossier" (lazy loaded)
    bool detailsLoading = false;
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
        MessageBodyRole,
        DetailsRole,
        DetailsLoadingRole
    };

    explicit GitLogModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    Q_INVOKABLE void parseAndSetLog(const QString &log);
    Q_INVOKABLE void updateDetails(const QString &sha, const QString &details);
    Q_INVOKABLE void setDetailsLoading(const QString &sha, bool loading);
    Q_INVOKABLE QString shaAt(int index) const;

protected:
    QHash<int, QByteArray> roleNames() const override;

private:
    QList<GitCommit> m_commits;
};

#endif // GITLOGMODEL_H
