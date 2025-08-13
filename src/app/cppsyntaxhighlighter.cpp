#include "cppsyntaxhighlighter.h"

CppSyntaxHighlighter::CppSyntaxHighlighter(QTextDocument *parent)
    : QSyntaxHighlighter(parent)
{
    HighlightingRule rule;

    // Keywords
    keywordFormat.setForeground(QColor(250, 0, 60)); // Red
    QStringList keywordPatterns = {
        QStringLiteral("\\bclass\\b"), QStringLiteral("\\bint\\b"), QStringLiteral("\\breturn\\b"),
        QStringLiteral("\\bif\\b"),    QStringLiteral("\\belse\\b"),  QStringLiteral("\\bfor\\b"),
        QStringLiteral("\\bwhile\\b"), QStringLiteral("\\bpublic\\b"), QStringLiteral("\\bprivate\\b"),
        QStringLiteral("\\busing\\b")
    };
    for (const QString &pattern : keywordPatterns) {
        rule.pattern = QRegularExpression(pattern);
        rule.format = keywordFormat;
        highlightingRules.append(rule);
    }

    // Includes
    includeFormat.setForeground(QColor(205, 154, 88)); // Orange
    rule.pattern = QRegularExpression(QStringLiteral("^\\s*#include\\s*[<\"][^>\"]*[\">]"));
    rule.format = includeFormat;
    highlightingRules.append(rule);

    // Macros
    macroFormat.setForeground(QColor(255, 184, 108)); // Orange
    rule.pattern = QRegularExpression(QStringLiteral("^\\s*#define.*"));
    rule.format = macroFormat;
    highlightingRules.append(rule);

    // Single-line comments
    singleLineCommentFormat.setForeground(QColor(150, 105, 140));

    // Multi-line comments
    multiLineCommentFormat.setForeground(QColor(150, 105, 140));

    // Strings
    stringFormat.setForeground(QColor(0, 220, 0)); // green
}

void CppSyntaxHighlighter::highlightBlock(const QString &text)
{
    // 1. Apply stateless rules (keywords, includes, macros)
    for (const HighlightingRule &rule : highlightingRules) {
        QRegularExpressionMatchIterator matchIterator = rule.pattern.globalMatch(text);
        while (matchIterator.hasNext()) {
            QRegularExpressionMatch match = matchIterator.next();
            setFormat(match.capturedStart(), match.capturedLength(), rule.format);
        }
    }

    // 2. Handle strings
    QRegularExpression stringExpression(QStringLiteral("\"([^\"\\\\]|\\\\.)*\""));
    QRegularExpressionMatchIterator stringIterator = stringExpression.globalMatch(text);
    while (stringIterator.hasNext()) {
        QRegularExpressionMatch match = stringIterator.next();
        setFormat(match.capturedStart(), match.capturedLength(), stringFormat);
    }

    // 3. Handle single-line comments
    QRegularExpression singleLineCommentExpression(QStringLiteral("//[^\n]*"));
    QRegularExpressionMatchIterator slcIterator = singleLineCommentExpression.globalMatch(text);
    while (slcIterator.hasNext()) {
        QRegularExpressionMatch match = slcIterator.next();
        setFormat(match.capturedStart(), match.capturedLength(), singleLineCommentFormat);
    }

    // 4. Handle multi-line comments
    setCurrentBlockState(Normal);
    int startIndex = 0;
    if (previousBlockState() != InComment) {
        startIndex = text.indexOf(QRegularExpression("/\\*"));
    }

    while (startIndex >= 0) {
        QRegularExpressionMatch endMatch;
        int endIndex = text.indexOf(QRegularExpression("\\*/"), startIndex + 2);
        int commentLength;
        if (endIndex == -1) {
            setCurrentBlockState(InComment);
            commentLength = text.length() - startIndex;
        } else {
            commentLength = endIndex - startIndex + 2;
        }
        setFormat(startIndex, commentLength, multiLineCommentFormat);
        startIndex = text.indexOf(QRegularExpression("/\\*"), startIndex + commentLength);
    }
}
