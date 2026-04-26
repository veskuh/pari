#include "gitdiffmodel.h"
#include <QRegularExpression>

GitDiffModel::GitDiffModel(QObject *parent) : QAbstractListModel(parent)
{
}

int GitDiffModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_lines.size();
}

QVariant GitDiffModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_lines.size()) return QVariant();

    const GitDiffLine &line = m_lines[index.row()];

    switch (role) {
        case TypeRole: return static_cast<int>(line.type);
        case ContentRole: return line.content;
        case OldLineRole: return line.oldLineNumber > 0 ? QVariant(line.oldLineNumber) : QVariant(0);
        case NewLineRole: return line.newLineNumber > 0 ? QVariant(line.newLineNumber) : QVariant(0);
        case FilePathRole: return line.filePath;
        default: return QVariant();
    }
}

void GitDiffModel::parseRawDiff(const QString &rawDiff)
{
    beginResetModel();
    m_lines.clear();

    QStringList rawLines = rawDiff.split('\n');
    QString currentFilePath;
    int oldLine = 0;
    int newLine = 0;

    QList<GitDiffLine> untrackedLines;
    QList<GitDiffLine> statusLines;
    QList<GitDiffLine> actualDiffLines;
    bool inDiffPhase = false;

    QRegularExpression hunkHeader(R"(^@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@)");
    QRegularExpression porcelainStatus(R"(^([ MADRCU?][ MADRCU?])\s+(.+)$)");

    for (const QString &line : rawLines) {
        if (line.isEmpty()) continue;

        if (line.startsWith("diff --git")) {
            inDiffPhase = true;
        }

        if (!inDiffPhase) {
            auto match = porcelainStatus.match(line);
            if (match.hasMatch()) {
                GitDiffLine sl;
                QString code = match.captured(1);
                QString path = match.captured(2);
                
                if (code == "??") {
                    sl.type = GitDiffLine::UntrackedFile;
                    sl.content = path;
                } else {
                    sl.type = GitDiffLine::StatusFile;
                    sl.content = QString("[%1] %2").arg(code.trimmed()).arg(path);
                }
                sl.filePath = path;
                sl.oldLineNumber = -1;
                sl.newLineNumber = -1;
                
                if (code == "??") untrackedLines.append(sl);
                else statusLines.append(sl);
                continue;
            }
            continue; 
        }

        if (line.startsWith("index ") || line.startsWith("--- ") || line.startsWith("+++ ")) {
            continue;
        }

        GitDiffLine diffLine;
        diffLine.type = GitDiffLine::Context; 
        diffLine.content = line;
        diffLine.filePath = currentFilePath;
        diffLine.oldLineNumber = -1;
        diffLine.newLineNumber = -1;

        if (line.startsWith("diff --git")) {
            diffLine.type = GitDiffLine::FileHeader;
            QStringList parts = line.split(" ");
            if (parts.size() >= 4) {
                QString pathA = parts[2].mid(2);
                QString pathB = parts[3].mid(2);
                if (pathA == pathB) {
                    currentFilePath = pathA;
                    diffLine.content = pathA;
                } else {
                    currentFilePath = pathB;
                    diffLine.content = QString("%1 → %2").arg(pathA).arg(pathB);
                }
                diffLine.filePath = currentFilePath;
            }
            actualDiffLines.append(diffLine);
        } else {
            auto match = hunkHeader.match(line);
            if (match.hasMatch()) {
                diffLine.type = GitDiffLine::HunkHeader;
                oldLine = match.captured(1).toInt();
                newLine = match.captured(2).toInt();
                actualDiffLines.append(diffLine);
            } else if (line.startsWith('+')) {
                diffLine.type = GitDiffLine::Addition;
                diffLine.newLineNumber = newLine++;
                actualDiffLines.append(diffLine);
            } else if (line.startsWith('-')) {
                diffLine.type = GitDiffLine::Deletion;
                diffLine.oldLineNumber = oldLine++;
                actualDiffLines.append(diffLine);
            } else if (line.startsWith(' ')) {
                diffLine.type = GitDiffLine::Context;
                diffLine.oldLineNumber = oldLine++;
                diffLine.newLineNumber = newLine++;
                actualDiffLines.append(diffLine);
            } else if (line.startsWith("rename ") || line.startsWith("similarity ") || line.startsWith("new file ") || line.startsWith("deleted file ")) {
                diffLine.type = GitDiffLine::FileHeader;
                actualDiffLines.append(diffLine);
            } else {
                actualDiffLines.append(diffLine);
            }
        }
    }

    m_lines.append(untrackedLines);
    m_lines.append(statusLines);
    m_lines.append(actualDiffLines);

    endResetModel();
    emit countChanged();
}

void GitDiffModel::clear()
{
    beginResetModel();
    m_lines.clear();
    endResetModel();
    emit countChanged();
}

QHash<int, QByteArray> GitDiffModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[TypeRole] = "type";
    roles[ContentRole] = "content";
    roles[OldLineRole] = "oldLine";
    roles[NewLineRole] = "newLine";
    roles[FilePathRole] = "filePath";
    return roles;
}
