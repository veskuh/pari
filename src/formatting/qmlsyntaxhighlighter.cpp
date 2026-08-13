#include "qmlsyntaxhighlighter.h"
#include "syntaxtheme.h"
#include <utility>

QmlSyntaxHighlighter::QmlSyntaxHighlighter(QTextDocument *parent, SyntaxTheme *theme)
    : QSyntaxHighlighter(parent), m_theme(theme)
{
    HighlightingRule rule;

    if (!m_theme) {
        return;
    }

    // Keyword format
    keywordFormat.setForeground(m_theme->keywordColor);
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
    componentFormat.setForeground(m_theme->typeColor);
    rule.pattern = QRegularExpression("\\b[A-Z][a-zA-Z0-9]+\\b");
    rule.format = componentFormat;
    highlightingRules.append(rule);

    // String format
    stringFormat.setForeground(m_theme->stringColor);

    // Single line comment format
    singleLineCommentFormat.setForeground(m_theme->commentColor);

    // Multi-line comment format
    multiLineCommentFormat.setForeground(m_theme->commentColor);
    multiLineCommentStartExpression = QRegularExpression("/\\*");
    multiLineCommentEndExpression = QRegularExpression("\\*/");
}

void QmlSyntaxHighlighter::highlightBlock(const QString &text)
{
    // Apply stateless rules (keywords, components)
    for (const HighlightingRule &rule : std::as_const(highlightingRules)) {
        QRegularExpressionMatchIterator matchIterator = rule.pattern.globalMatch(text);
        while (matchIterator.hasNext()) {
            QRegularExpressionMatch match = matchIterator.next();
            setFormat(match.capturedStart(), match.capturedLength(), rule.format);
        }
    }

    // Strings
    static const QRegularExpression stringExpression(QStringLiteral("\"([^\"\\\\]|\\\\.)*\""));
    QRegularExpressionMatchIterator stringIterator = stringExpression.globalMatch(text);
    while (stringIterator.hasNext()) {
        QRegularExpressionMatch match = stringIterator.next();
        setFormat(match.capturedStart(), match.capturedLength(), stringFormat);
    }

    // Single-line comments
    static const QRegularExpression singleLineCommentExpression(QStringLiteral("//[^\n]*"));
    QRegularExpressionMatchIterator slcIterator = singleLineCommentExpression.globalMatch(text);
    while (slcIterator.hasNext()) {
        QRegularExpressionMatch match = slcIterator.next();
        setFormat(match.capturedStart(), match.capturedLength(), singleLineCommentFormat);
    }

    // Multi-line comments
    setCurrentBlockState(Normal);
    int startIndex = 0;
    bool startedInComment = false;
    if (previousBlockState() != InComment) {
        startIndex = text.indexOf(multiLineCommentStartExpression);
    } else {
        startedInComment = true;
    }

    while (startIndex >= 0) {
        int searchStart = startedInComment ? startIndex : startIndex + 2;
        QRegularExpressionMatch endMatch = multiLineCommentEndExpression.match(text, searchStart);
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
        startedInComment = false;
    }
}
