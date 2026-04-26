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
    QList<GitDiffLine> actualDiffLines;

    QRegularExpression hunkHeader(R"(^@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@)");

    for (const QString &line : rawLines) {
        if (line.isEmpty()) continue;

        // --- 1. HANDLE UNTRACKED FILES (?? marker) ---
        if (line.startsWith("?? ")) {
            GitDiffLine untracked;
            untracked.type = GitDiffLine::UntrackedFile;
            untracked.content = line.mid(3); // Just the path
            untracked.filePath = untracked.content;
            untracked.oldLineNumber = -1;
            untracked.newLineNumber = -1;
            untrackedLines.append(untracked);
            continue;
        }

        // SKIP NOISY HEADERS
        if (line.startsWith("index ") || line.startsWith("--- ") || line.startsWith("+++ ")) {
            continue;
        }

        GitDiffLine diffLine;
        diffLine.content = line;
        diffLine.filePath = currentFilePath;
        diffLine.oldLineNumber = -1;
        diffLine.newLineNumber = -1;

        if (line.startsWith("diff --git")) {
            diffLine.type = GitDiffLine::FileHeader;
            QStringList parts = line.split(" ");
            if (parts.size() >= 4) {
                QString pathA = parts[2].mid(2); // Remove "a/"
                QString pathB = parts[3].mid(2); // Remove "b/"
                
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
            }
        }
    }

    // Combine: Header for Untracked (if any) + Untracked Files + Actual Diff
    if (!untrackedLines.isEmpty()) {
        GitDiffLine header;
        header.type = GitDiffLine::FileHeader;
        header.content = QString("Untracked Files (%1)").arg(untrackedLines.size());
        m_lines.append(header);
        m_lines.append(untrackedLines);
        
        // Add a spacer hunk header if we have actual diffs coming up
        if (!actualDiffLines.isEmpty()) {
             GitDiffLine spacer;
             spacer.type = GitDiffLine::HunkHeader;
             spacer.content = "--- Workspace Changes ---";
             m_lines.append(spacer);
        }
    }
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
