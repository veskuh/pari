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
    Q_PROPERTY(QString filterText READ filterText WRITE setFilterText NOTIFY filterTextChanged)

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

    QString filterText() const { return m_filterText; }
    void setFilterText(const QString &text);

signals:
    void filterTextChanged();

protected:
    QHash<int, QByteArray> roleNames() const override;

private:
    void applyFilter();
    QList<GitCommit> m_allCommits;
    QList<GitCommit> m_visibleCommits;
    QString m_filterText;
};

#endif // GITLOGMODEL_H
