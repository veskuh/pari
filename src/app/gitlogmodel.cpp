#include "gitlogmodel.h"
#include <QDebug>

GitLogModel::GitLogModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int GitLogModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_commits.count();
}

QVariant GitLogModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_commits.count())
        return QVariant();

    const GitCommit &commit = m_commits[index.row()];

    switch (role) {
    case ShaRole:
        return commit.sha;
    case AuthorNameRole:
        return commit.authorName;
    case AuthorEmailRole:
        return commit.authorEmail;
    case DateRole:
        return commit.authorDate.date().toString(Qt::ISODate);
    case TimeRole:
        return commit.authorDate.time().toString(Qt::ISODate);
    case MessageHeaderRole:
        return commit.messageHeader;
    case MessageBodyRole:
        return commit.messageBody;
    default:
        return QVariant();
    }
}

void GitLogModel::parseAndSetLog(const QString &log)
{
    beginResetModel();
    m_commits.clear();
    const QString recordSeparator = QString(QChar(0x1e));
    const QString unitSeparator = QString(QChar(0x1f));
    QStringList entries = log.split(recordSeparator, Qt::SkipEmptyParts);

    for (const QString &entry : entries) {
        QStringList fields = entry.split(unitSeparator);
        if (fields.count() >= 5) {
            GitCommit commit;
            commit.sha = fields[0];
            commit.authorName = fields[1];
            commit.authorEmail = fields[2];
            commit.authorDate = QDateTime::fromString(fields[3], Qt::RFC2822Date);

            QString fullMessage = fields[4];
            int newlinePos = fullMessage.indexOf('\n');
            if (newlinePos == -1) {
                commit.messageHeader = fullMessage.trimmed();
                commit.messageBody = "";
            } else {
                commit.messageHeader = fullMessage.left(newlinePos).trimmed();
                commit.messageBody = fullMessage.mid(newlinePos + 1).trimmed();
            }

            m_commits.append(commit);
        }
    }
    endResetModel();
}

QHash<int, QByteArray> GitLogModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[ShaRole] = "sha";
    roles[AuthorNameRole] = "authorName";
    roles[AuthorEmailRole] = "authorEmail";
    roles[DateRole] = "date";
    roles[TimeRole] = "time";
    roles[MessageHeaderRole] = "messageHeader";
    roles[MessageBodyRole] = "messageBody";
    return roles;
}
