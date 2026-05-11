#include "projectsearchmodel.h"
#include "documentmanager.h"
#include "textdocument.h"
#include "syntaxhighlighterprovider.h"
#include <QtConcurrent>
#include <QDirIterator>
#include <QFileInfo>
#include <QFile>
#include <QTextStream>
#include <QRegularExpression>
#include <QSet>

ProjectSearchModel::ProjectSearchModel(QObject *parent)
    : QAbstractListModel(parent)
{
    connect(&m_watcher, &QFutureWatcher<QList<SearchResult>>::finished, this, &ProjectSearchModel::onSearchFinished);
}

int ProjectSearchModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_results.count();
}

QVariant ProjectSearchModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_results.count())
        return QVariant();

    const SearchResult &result = m_results.at(index.row());

    switch (role) {
    case FilePathRole:
        return result.filePath;
    case FileNameRole:
        return QFileInfo(result.filePath).fileName();
    case LineNumberRole:
        return result.lineNumber;
    case LineTextRole:
        return result.lineText;
    case MatchStartRole:
        return result.matchStart;
    case MatchLengthRole:
        return result.matchLength;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> ProjectSearchModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[FilePathRole] = "filePath";
    roles[FileNameRole] = "fileName";
    roles[LineNumberRole] = "lineNumber";
    roles[LineTextRole] = "lineText";
    roles[MatchStartRole] = "matchStart";
    roles[MatchLengthRole] = "matchLength";
    return roles;
}

void ProjectSearchModel::search(const QString &rootPath, const QString &pattern, 
                               bool matchCase, bool useRegex, const QString &scopeFilter)
{
    if (m_isSearching) return;

    clear();
    m_isSearching = true;
    m_lastPattern = pattern;
    m_lastMatchCase = matchCase;
    m_lastUseRegex = useRegex;
    emit isSearchingChanged();

    QMap<QString, QString> openDocs;
    if (m_docManager) {
        for (auto *obj : m_docManager->documents()) {
            TextDocument *doc = qobject_cast<TextDocument*>(obj);
            if (doc) {
                openDocs[doc->filePath()] = doc->text();
            }
        }
    }

    QFuture<QList<SearchResult>> future = QtConcurrent::run(&ProjectSearchModel::performSearch, 
                                                            rootPath, pattern, matchCase, useRegex, 
                                                            scopeFilter, openDocs);
    m_watcher.setFuture(future);
}

void ProjectSearchModel::cancel()
{
    if (m_isSearching) {
        m_watcher.cancel();
    }
}

void ProjectSearchModel::clear()
{
    beginResetModel();
    m_results.clear();
    endResetModel();
    emit resultCountChanged();
}

void ProjectSearchModel::replaceAll(const QString &replaceText)
{
    if (m_results.isEmpty() || m_lastPattern.isEmpty()) return;

    QSet<QString> uniqueFiles;
    for (const auto &res : m_results) {
        uniqueFiles.insert(res.filePath);
    }

    QRegularExpression re;
    if (m_lastUseRegex) {
        re.setPattern(m_lastPattern);
        if (!m_lastMatchCase) re.setPatternOptions(QRegularExpression::CaseInsensitiveOption);
    }

    for (const QString &filePath : uniqueFiles) {
        QString content;
        bool isOpen = false;
        int docIndex = -1;

        if (m_docManager) {
            auto docs = m_docManager->documents();
            for (int i = 0; i < docs.size(); ++i) {
                TextDocument *doc = qobject_cast<TextDocument*>(docs[i]);
                if (doc && doc->filePath() == filePath) {
                    content = doc->text();
                    isOpen = true;
                    docIndex = i;
                    break;
                }
            }
        }

        if (!isOpen) {
            QFile file(filePath);
            if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) continue;
            content = QString::fromUtf8(file.readAll());
            file.close();
        }

        QString newContent = content;
        if (m_lastUseRegex) {
            newContent.replace(re, replaceText);
        } else {
            newContent.replace(m_lastPattern, replaceText, m_lastMatchCase ? Qt::CaseSensitive : Qt::CaseInsensitive);
        }

        if (newContent != content) {
            if (isOpen) {
                // Update via DocumentManager so signals trigger and marks dirty
                m_docManager->saveFile(docIndex, newContent); 
                // wait, saveFile actually writes to disk. 
                // Better: update text directly and mark dirty.
                TextDocument *doc = qobject_cast<TextDocument*>(m_docManager->documents()[docIndex]);
                doc->setText(newContent);
                m_docManager->markDirty(docIndex);
            } else {
                QFile file(filePath);
                if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
                    QTextStream out(&file);
                    out << newContent;
                    file.close();
                }
            }
        }
    }
    
    clear();
}

void ProjectSearchModel::onSearchFinished()
{
    if (m_watcher.isCanceled()) {
        m_isSearching = false;
        emit isSearchingChanged();
        return;
    }

    beginResetModel();
    m_results = m_watcher.result();
    endResetModel();

    m_isSearching = false;
    emit isSearchingChanged();
    emit resultCountChanged();
    emit searchFinished();
}

void ProjectSearchModel::performSearch(QPromise<QList<SearchResult>> &promise,
                                     const QString &rootPath, const QString &pattern,
                                     bool matchCase, bool useRegex, const QString &scopeFilter,
                                     const QMap<QString, QString> &openDocuments)
{
    QList<SearchResult> results;
    if (rootPath.isEmpty() || pattern.isEmpty()) {
        promise.addResult(results);
        return;
    }

    QRegularExpression re;
    if (useRegex) {
        re.setPattern(pattern);
        if (!matchCase) re.setPatternOptions(QRegularExpression::CaseInsensitiveOption);
    }

    QStringList filters;
    if (!scopeFilter.isEmpty() && scopeFilter != "*") {
        QStringList rawFilters = scopeFilter.split(',', Qt::SkipEmptyParts);
        for (const QString &f : rawFilters) {
            QString trimmed = f.trimmed();
            if (trimmed.contains('*') || trimmed.contains('?')) {
                filters << trimmed;
            } else {
                filters << "*." + trimmed;
            }
        }
    } else {
        for (const QString &ext : SyntaxHighlighterProvider::supportedExtensions()) {
            filters << "*." + ext;
        }
        for (const QString &fileName : SyntaxHighlighterProvider::supportedFileNames()) {
            filters << fileName;
        }
    }

    QDirIterator it(rootPath, filters, QDir::Files | QDir::NoDotAndDotDot, QDirIterator::Subdirectories);
    while (it.hasNext()) {
        if (promise.isCanceled()) return;

        QString filePath = it.next();
        
        static const QStringList binaryExts = {".png", ".jpg", ".jpeg", ".gif", ".o", ".a", ".so", ".dylib", ".exe", ".pari"};
        bool isBinary = false;
        for (const QString &ext : binaryExts) {
            if (filePath.endsWith(ext, Qt::CaseInsensitive)) {
                isBinary = true;
                break;
            }
        }
        if (isBinary) continue;

        // --- Filename Match ---
        QString fileName = QFileInfo(filePath).fileName();
        if (useRegex) {
            QRegularExpressionMatch match = re.match(fileName);
            if (match.hasMatch()) {
                SearchResult res;
                res.filePath = filePath;
                res.lineNumber = 0; // Convention for filename match
                res.lineText = fileName;
                res.matchStart = match.capturedStart();
                res.matchLength = match.capturedLength();
                results.append(res);
            }
        } else {
            Qt::CaseSensitivity cs = matchCase ? Qt::CaseSensitive : Qt::CaseInsensitive;
            int pos = fileName.indexOf(pattern, 0, cs);
            if (pos != -1) {
                SearchResult res;
                res.filePath = filePath;
                res.lineNumber = 0;
                res.lineText = fileName;
                res.matchStart = pos;
                res.matchLength = pattern.length();
                results.append(res);
            }
        }

        QString content;
        if (openDocuments.contains(filePath)) {
            content = openDocuments.value(filePath);
        } else {
            QFile file(filePath);
            if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) continue;
            content = QString::fromUtf8(file.readAll());
            if (content.contains(QChar('\0'))) continue;
        }

        QStringList lines = content.split('\n');
        for (int i = 0; i < lines.count(); ++i) {
            if (promise.isCanceled()) return;

            const QString &line = lines.at(i);
            
            if (useRegex) {
                QRegularExpressionMatchIterator matchIt = re.globalMatch(line);
                while (matchIt.hasNext()) {
                    if (promise.isCanceled()) return;
                    QRegularExpressionMatch match = matchIt.next();
                    SearchResult res;
                    res.filePath = filePath;
                    res.lineNumber = i + 1;
                    res.lineText = line.trimmed();
                    res.matchStart = match.capturedStart();
                    res.matchLength = match.capturedLength();
                    results.append(res);
                }
            } else {
                Qt::CaseSensitivity cs = matchCase ? Qt::CaseSensitive : Qt::CaseInsensitive;
                int pos = 0;
                while ((pos = line.indexOf(pattern, pos, cs)) != -1) {
                    if (promise.isCanceled()) return;
                    SearchResult res;
                    res.filePath = filePath;
                    res.lineNumber = i + 1;
                    res.lineText = line.trimmed();
                    res.matchStart = pos;
                    res.matchLength = pattern.length();
                    results.append(res);
                    pos += pattern.length();
                }
            }
        }
    }

    promise.addResult(results);
}
