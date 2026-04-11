#include "textdocumentsearcher.h"
#include <QTextCursor>
#include <QQuickTextDocument>
#include <QTextDocument>

// We use a trick to support both real QQuickTextDocument and our Mock
// without needing to include mock headers in src.
// We can use QMetaObject to call textDocument() if it exists.

TextDocumentSearcher::TextDocumentSearcher(QObject *parent)
    : QObject{parent}
{

}

int TextDocumentSearcher::find(QObject *doc, const QString &subString, int from, int options)
{
    if (!doc) return -1;

    QTextDocument *textDocument = nullptr;

    // Try QQuickTextDocument first
    QQuickTextDocument *qquickTextDocument = qobject_cast<QQuickTextDocument*>(doc);
    if (qquickTextDocument) {
        textDocument = qquickTextDocument->textDocument();
    } else {
        // Fallback: try to call textDocument() via invokable or property
        // This handles our MockTextDocument in tests
        QVariant res;
        if (QMetaObject::invokeMethod(doc, "textDocument", Q_RETURN_ARG(QTextDocument*, textDocument))) {
            // success
        } else {
            // Try property if it's not a method
            textDocument = doc->property("textDocument").value<QTextDocument*>();
        }
    }

    if (!textDocument) {
        return -1;
    }

    QTextCursor cursor = textDocument->find(subString, from, QTextDocument::FindFlags(options));
    if (cursor.isNull()) {
        return -1;
    }

    return cursor.position();
}
