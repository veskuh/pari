#include "textdocumentsearcher.h"
#include <QTextCursor>
#include <QQuickTextDocument>
#include <QTextDocument>
#include <QRegularExpression>

TextDocumentSearcher::TextDocumentSearcher(QObject *parent)
    : QObject{parent}
{
}

QVariantMap TextDocumentSearcher::find(QObject *doc, const QString &subString, int from, int options, bool useRegex)
{
    QVariantMap result;
    result["position"] = -1;
    result["start"] = -1;
    result["end"] = -1;

    if (!doc) return result;

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

    if (!textDocument) return result;

    QTextCursor cursor;
    if (useRegex) {
        QRegularExpression::PatternOptions patternOptions = QRegularExpression::NoPatternOption;
        if (!(options & QTextDocument::FindCaseSensitively)) {
            patternOptions |= QRegularExpression::CaseInsensitiveOption;
        }
        QRegularExpression re(subString, patternOptions);
        if (!re.isValid()) return result;
        cursor = textDocument->find(re, from, QTextDocument::FindFlags(options));
    } else {
        cursor = textDocument->find(subString, from, QTextDocument::FindFlags(options));
    }
    
    if (cursor.isNull()) return result;

    result["position"] = cursor.position();
    result["start"] = cursor.selectionStart();
    result["end"] = cursor.selectionEnd();
    return result;
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
