#include "textdocumentsearcher.h"
#include <QTextCursor>
#include <QQuickTextDocument>

TextDocumentSearcher::TextDocumentSearcher(QObject *parent)
    : QObject{parent}
{

}

int TextDocumentSearcher::find(QObject *doc, const QString &subString, int from, int options)
{
    QQuickTextDocument *qquickTextDocument = qobject_cast<QQuickTextDocument*>(doc);
    if (!qquickTextDocument) {
        return -1;
    }
    QTextDocument *textDocument = qquickTextDocument->textDocument();
    if (!textDocument) {
        return -1;
    }

    QTextCursor cursor = textDocument->find(subString, from, QTextDocument::FindFlags(options));
    if (cursor.isNull()) {
        return -1;
    }

    return cursor.position();
}
