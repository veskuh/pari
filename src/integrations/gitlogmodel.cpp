#include "gitlogmodel.h"

GitLogModel::GitLogModel(QObject *parent) : QAbstractListModel(parent)
{
}

int GitLogModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_visibleCommits.size();
}

QVariant GitLogModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_visibleCommits.size()) return QVariant();

    const GitCommit &commit = m_visibleCommits[index.row()];

    switch (role) {
        case ShaRole: return commit.sha;
        case AuthorNameRole: return commit.authorName;
        case AuthorEmailRole: return commit.authorEmail;
        case DateRole: return commit.date;
        case TimeRole: return commit.time;
        case MessageHeaderRole: return commit.messageHeader;
        case MessageBodyRole: return commit.messageBody;
        case DetailsRole: return commit.details;
        case DetailsLoadingRole: return commit.detailsLoading;
        default: return QVariant();
    }
}

void GitLogModel::parseAndSetLog(const QString &log)
{
    m_allCommits.clear();

    QStringList commitEntries = log.split(QChar(0x1e), Qt::SkipEmptyParts);
    for (const QString &entry : commitEntries) {
        QStringList fields = entry.split(QChar(0x1f));
        if (fields.size() >= 5) {
            GitCommit commit;
            commit.sha = fields[0].trimmed();
            commit.authorName = fields[1];
            commit.authorEmail = fields[2];
            
            QDateTime dt = QDateTime::fromString(fields[3].trimmed(), Qt::RFC2822Date);
            commit.authorDate = dt;
            commit.date = dt.date().toString("yyyy-MM-dd");
            commit.time = dt.time().toString("HH:mm");
            
            const QString& message = fields[4];
            int firstNewline = message.indexOf('\n');
            if (firstNewline != -1) {
                commit.messageHeader = message.left(firstNewline).trimmed();
                commit.messageBody = message.mid(firstNewline).trimmed();
            } else {
                commit.messageHeader = message.trimmed();
                commit.messageBody = "";
            }
            m_allCommits.append(commit);
        }
    }
    applyFilter();
}

void GitLogModel::updateDetails(const QString &sha, const QString &details)
{
    if (sha.isEmpty()) return;

    for (int i = 0; i < m_allCommits.size(); ++i) {
        if (m_allCommits[i].sha == sha) {
            m_allCommits[i].details = details;
            m_allCommits[i].detailsLoading = false;
            break;
        }
    }

    for (int i = 0; i < m_visibleCommits.size(); ++i) {
        if (m_visibleCommits[i].sha == sha) {
            m_visibleCommits[i].details = details;
            m_visibleCommits[i].detailsLoading = false;
            QModelIndex idx = index(i, 0);
            if (idx.isValid()) {
                emit dataChanged(idx, idx, {DetailsRole, DetailsLoadingRole});
            }
            return;
        }
    }
}

void GitLogModel::setDetailsLoading(const QString &sha, bool loading)
{
    if (sha.isEmpty()) return;

    for (int i = 0; i < m_allCommits.size(); ++i) {
        if (m_allCommits[i].sha == sha) {
            m_allCommits[i].detailsLoading = loading;
            break;
        }
    }

    for (int i = 0; i < m_visibleCommits.size(); ++i) {
        if (m_visibleCommits[i].sha == sha) {
            m_visibleCommits[i].detailsLoading = loading;
            QModelIndex idx = index(i, 0);
            if (idx.isValid()) {
                emit dataChanged(idx, idx, {DetailsLoadingRole});
            }
            return;
        }
    }
}

QString GitLogModel::shaAt(int index) const
{
    if (index >= 0 && index < m_visibleCommits.size()) {
        return m_visibleCommits[index].sha;
    }
    return QString();
}

void GitLogModel::setFilterText(const QString &text)
{
    if (m_filterText == text) return;
    m_filterText = text;
    applyFilter();
    emit filterTextChanged();
}

void GitLogModel::applyFilter()
{
    beginResetModel();
    if (m_filterText.isEmpty()) {
        m_visibleCommits = m_allCommits;
    } else {
        m_visibleCommits.clear();
        QString filter = m_filterText.toLower();
        for (const auto &commit : m_allCommits) {
            if (commit.sha.toLower().contains(filter) ||
                commit.authorName.toLower().contains(filter) ||
                commit.messageHeader.toLower().contains(filter) ||
                commit.messageBody.toLower().contains(filter)) {
                m_visibleCommits.append(commit);
            }
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
    roles[DetailsRole] = "details";
    roles[DetailsLoadingRole] = "detailsLoading";
    return roles;
}
