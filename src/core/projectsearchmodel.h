#ifndef PROJECTSEARCHMODEL_H
#define PROJECTSEARCHMODEL_H

#include <QAbstractListModel>
#include <QStringList>
#include <QColor>
#include <QFutureWatcher>

class DocumentManager;

struct SearchResult {
    QString filePath;
    int lineNumber;
    QString lineText;
    int matchStart;
    int matchLength;
};

class ProjectSearchModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(bool isSearching READ isSearching NOTIFY isSearchingChanged)
    Q_PROPERTY(int resultCount READ resultCount NOTIFY resultCountChanged)

public:
    enum SearchRoles {
        FilePathRole = Qt::UserRole + 1,
        FileNameRole,
        LineNumberRole,
        LineTextRole,
        MatchStartRole,
        MatchLengthRole
    };

    explicit ProjectSearchModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void search(const QString &rootPath, const QString &pattern, 
                           bool matchCase, bool useRegex, const QString &scopeFilter);
    Q_INVOKABLE void clear();
    Q_INVOKABLE void replaceAll(const QString &replaceText);

    bool isSearching() const { return m_isSearching; }
    int resultCount() const { return m_results.count(); }

    void setDocumentManager(DocumentManager *docManager) { m_docManager = docManager; }

signals:
    void isSearchingChanged();
    void resultCountChanged();
    void searchFinished();

private slots:
    void onSearchFinished();

private:
    QList<SearchResult> m_results;
    bool m_isSearching = false;
    DocumentManager *m_docManager = nullptr;
    QFutureWatcher<QList<SearchResult>> m_watcher;
    QString m_lastPattern;
    bool m_lastMatchCase = false;
    bool m_lastUseRegex = false;

    // Helper for background search
    static QList<SearchResult> performSearch(const QString &rootPath, const QString &pattern,
                                           bool matchCase, bool useRegex, const QString &scopeFilter,
                                           const QMap<QString, QString> &openDocuments);
};

#endif // PROJECTSEARCHMODEL_H
