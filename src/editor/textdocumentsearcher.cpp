#include "textdocumentsearcher.h"
#include <QTextCursor>
#include <QQuickTextDocument>
#include <QTextDocument>

TextDocumentSearcher::TextDocumentSearcher(QObject *parent)
    : QObject{parent}
{
}

int TextDocumentSearcher::find(QObject *doc, const QString &subString, int from, int options)
{
    if (!doc) return -1;

    QTextDocument *textDocument = qobject_cast<QTextDocument*>(doc);

    if (!textDocument) {
        QQuickTextDocument *qquickTextDocument = qobject_cast<QQuickTextDocument*>(doc);
        if (qquickTextDocument) {
            textDocument = qquickTextDocument->textDocument();
        } else {
            if (!QMetaObject::invokeMethod(doc, "textDocument", Q_RETURN_ARG(QTextDocument*, textDocument))) {
                textDocument = doc->property("textDocument").value<QTextDocument*>();
            }
        }
    }

    if (!textDocument) return -1;

    QTextCursor cursor = textDocument->find(subString, from, QTextDocument::FindFlags(options));
    if (cursor.isNull()) return -1;

    return cursor.position();
}

void TextDocumentSearcher::applyFilter(QObject *doc, const QString &pattern, bool isRegex, bool matchCase)
{
    Q_UNUSED(doc);
    Q_UNUSED(pattern);
    Q_UNUSED(isRegex);
    Q_UNUSED(matchCase);
}

void TextDocumentSearcher::clearFilter(QObject *doc)
{
    Q_UNUSED(doc);
}
