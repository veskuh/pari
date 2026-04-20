#include "gitblamemodel.h"
#include <QHash>
#include <QRegularExpression>
#include <QDateTime>
#include <QDebug>

GitBlameModel::GitBlameModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int GitBlameModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_lines.count();
}

QVariant GitBlameModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_lines.count())
        return QVariant();

    const BlameLine &line = m_lines.at(index.row());

    switch (role) {
    case HashRole: return line.hash;
    case AuthorRole: return line.author;
    case EmailRole: return line.email;
    case DateRole: return line.date;
    case ContentRole: return line.content;
    case ColorRole: return line.color;
    case ShowMetadataRole: return line.showMetadata;
    default: return QVariant();
    }
}

QHash<int, QByteArray> GitBlameModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[HashRole] = "hash";
    roles[AuthorRole] = "author";
    roles[EmailRole] = "email";
    roles[DateRole] = "date";
    roles[ContentRole] = "content";
    roles[ColorRole] = "color";
    roles[ShowMetadataRole] = "showMetadata";
    return roles;
}

void GitBlameModel::parseRawOutput(const QString &rawOutput)
{
    beginResetModel();
    m_lines.clear();
    m_colorCache.clear();

    if (rawOutput.isEmpty()) {
        endResetModel();
        return;
    }

    // We expect porcelain format:
    // hash source_line result_line num_lines
    // author Name
    // author-mail <email>
    // author-time timestamp
    // author-tz timezone
    // committer ... (etc)
    // summary ...
    // \t content
    
    QStringList lines = rawOutput.split('\n');
    BlameLine currentLine;
    QString lastHash;
    
    struct CommitInfo {
        QString author;
        QString email;
        QString date;
    };
    QHash<QString, CommitInfo> commitCache;

    for (int i = 0; i < lines.size(); ++i) {
        QString line = lines.at(i);
        if (line.isEmpty()) continue;

        // If it's a new commit block (starts with a 40-char hash or similar)
        static QRegularExpression hashRegex("^([0-9a-f]{40})");
        auto match = hashRegex.match(line);
        if (match.hasMatch()) {
            QString hash = match.captured(1).left(8);
            if (hash != currentLine.hash) {
                currentLine.hash = hash;
                if (commitCache.contains(hash)) {
                    CommitInfo info = commitCache.value(hash);
                    currentLine.author = info.author;
                    currentLine.email = info.email;
                    currentLine.date = info.date;
                } else {
                    currentLine.author = "";
                    currentLine.email = "";
                    currentLine.date = "";
                }
            }
        } else if (line.startsWith("author ")) {
            currentLine.author = line.mid(7);
        } else if (line.startsWith("author-mail ")) {
            currentLine.email = line.mid(12).remove('<').remove('>');
        } else if (line.startsWith("author-time ")) {
            qlonglong timestamp = line.mid(12).toLongLong();
            currentLine.date = QDateTime::fromSecsSinceEpoch(timestamp).toString("yyyy-MM-dd");
        } else if (line.startsWith('\t')) {
            // This is the actual source code line
            currentLine.content = line.mid(1);
            currentLine.color = getColorForHash(currentLine.hash);
            currentLine.showMetadata = (currentLine.hash != lastHash);
            
            // Cache commit info if we just learned it
            if (!currentLine.author.isEmpty() && !commitCache.contains(currentLine.hash)) {
                commitCache.insert(currentLine.hash, {currentLine.author, currentLine.email, currentLine.date});
            }
            
            m_lines.append(currentLine);
            lastHash = currentLine.hash;
        }
    }

    endResetModel();
    emit layoutChanged();
}

void GitBlameModel::clear()
{
    beginResetModel();
    m_lines.clear();
    m_colorCache.clear();
    endResetModel();
    emit layoutChanged();
}

QColor GitBlameModel::getColorForHash(const QString &hash)
{
    if (m_colorCache.contains(hash))
        return m_colorCache.value(hash);

    if (hash.startsWith("00000000")) return QColor("#888888");

    uint h = qHash(hash);
    QColor color = QColor::fromHsl(h % 360, 180, 150);
    m_colorCache.insert(hash, color);
    return color;
}
