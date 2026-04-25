#ifndef TEXTDOCUMENTSEARCHER_H
#define TEXTDOCUMENTSEARCHER_H

#include <QObject>

class QTextDocument;

class TextDocumentSearcher : public QObject
{
    Q_OBJECT
public:
    explicit TextDocumentSearcher(QObject *parent = nullptr);

    Q_INVOKABLE int find(QObject *doc, const QString &subString, int from, int options = 0);
    Q_INVOKABLE void applyFilter(QObject *doc, const QString &pattern, bool isRegex, bool matchCase);
    Q_INVOKABLE void clearFilter(QObject *doc);

signals:

};

#endif // TEXTDOCUMENTSEARCHER_H
