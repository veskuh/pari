#include "qmlsyntaxhighlighter.h"

QmlSyntaxHighlighter::QmlSyntaxHighlighter(QTextDocument *parent)
    : QSyntaxHighlighter(parent)
{
    HighlightingRule rule;

    // Keyword format
    keywordFormat.setForeground(QColor(255, 192, 203));
    QStringList keywordPatterns = {
        "\\bimport\\b", "\\bproperty\\b", "\\bfunction\\b", "\\bvar\\b", "\\brole\\b",
        "\\bsignal\\b", "\\benum\\b", "\\bfalse\\b", "\\btrue\\b", "\\bnull\\b",
        "\\bid\\b", "\\bon\\b"
    };
    for (const QString &pattern : keywordPatterns) {
        rule.pattern = QRegularExpression(pattern);
        rule.format = keywordFormat;
        highlightingRules.append(rule);
    }

    // Component format
    componentFormat.setForeground(QColor(135, 206, 250));
    rule.pattern = QRegularExpression("\\b[A-Z][a-zA-Z0-9]+\\b");
    rule.format = componentFormat;
    highlightingRules.append(rule);

    // String format
    stringFormat.setForeground(QColor(0, 255, 255));

    // Single line comment format
    singleLineCommentFormat.setForeground(QColor(128, 128, 128));

    // Multi-line comment format
    multiLineCommentFormat.setForeground(QColor(128, 128, 128));
    multiLineCommentStartExpression = QRegularExpression("/\\*");
    multiLineCommentEndExpression = QRegularExpression("\\*/");
}

void QmlSyntaxHighlighter::highlightBlock(const QString &text)
{
    // Apply stateless rules (keywords, components)
    for (const HighlightingRule &rule : highlightingRules) {
        QRegularExpressionMatchIterator matchIterator = rule.pattern.globalMatch(text);
        while (matchIterator.hasNext()) {
            QRegularExpressionMatch match = matchIterator.next();
            setFormat(match.capturedStart(), match.capturedLength(), rule.format);
        }
    }

    // Strings
    QRegularExpression stringExpression(QStringLiteral("\"([^\"\\\\]|\\\\.)*\""));
    QRegularExpressionMatchIterator stringIterator = stringExpression.globalMatch(text);
    while (stringIterator.hasNext()) {
        QRegularExpressionMatch match = stringIterator.next();
        setFormat(match.capturedStart(), match.capturedLength(), stringFormat);
    }

    // Single-line comments
    QRegularExpression singleLineCommentExpression(QStringLiteral("//[^\n]*"));
    QRegularExpressionMatchIterator slcIterator = singleLineCommentExpression.globalMatch(text);
    while (slcIterator.hasNext()) {
        QRegularExpressionMatch match = slcIterator.next();
        setFormat(match.capturedStart(), match.capturedLength(), singleLineCommentFormat);
    }

    // Multi-line comments
    setCurrentBlockState(Normal);
    int startIndex = 0;
    if (previousBlockState() != InComment) {
        startIndex = text.indexOf(multiLineCommentStartExpression);
    }

    while (startIndex >= 0) {
        QRegularExpressionMatch endMatch = multiLineCommentEndExpression.match(text, startIndex + 2);
        int endIndex = endMatch.capturedStart();
        int commentLength;
        if (endIndex == -1) {
            setCurrentBlockState(InComment);
            commentLength = text.length() - startIndex;
        } else {
            commentLength = endIndex - startIndex + endMatch.capturedLength();
        }
        setFormat(startIndex, commentLength, multiLineCommentFormat);
        startIndex = text.indexOf(multiLineCommentStartExpression, startIndex + commentLength);
    }
}
