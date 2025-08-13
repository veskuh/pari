#include "cppsyntaxhighlighter.h"

CppSyntaxHighlighter::CppSyntaxHighlighter(QTextDocument *parent)
    : QSyntaxHighlighter(parent)
{
    HighlightingRule rule;

    // Keywords
    keywordFormat.setForeground(QColor(255, 121, 198)); // Pink
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
    includeFormat.setForeground(QColor(255, 184, 108)); // Orange
    rule.pattern = QRegularExpression(QStringLiteral("^\\s*#include\\s*[<\"][^>\"]*[\">]"));
    rule.format = includeFormat;
    highlightingRules.append(rule);

    // Macros
    macroFormat.setForeground(QColor(255, 184, 108)); // Orange
    rule.pattern = QRegularExpression(QStringLiteral("^\\s*#define.*"));
    rule.format = macroFormat;
    highlightingRules.append(rule);

    // Single-line comments
    singleLineCommentFormat.setForeground(QColor(98, 114, 164)); // Grayish blue
    rule.pattern = QRegularExpression(QStringLiteral("//[^\n]*"));
    rule.format = singleLineCommentFormat;
    highlightingRules.append(rule);

    // Multi-line comments
    multiLineCommentFormat.setForeground(QColor(98, 114, 164));

    // Strings
    stringFormat.setForeground(QColor(241, 250, 140)); // Yellow
}

void CppSyntaxHighlighter::highlightBlock(const QString &text)
{
    // Apply all stateless rules first.
    for (const HighlightingRule &rule : highlightingRules) {
        QRegularExpressionMatchIterator matchIterator = rule.pattern.globalMatch(text);
        while (matchIterator.hasNext()) {
            QRegularExpressionMatch match = matchIterator.next();
            setFormat(match.capturedStart(), match.capturedLength(), rule.format);
        }
    }

    setCurrentBlockState(Normal);

    // Handle multi-line comments, which will override other formats.
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

    // Handle strings, which will override other formats.
    QRegularExpression stringExpression(QStringLiteral("\"([^\"\\\\]|\\\\.)*\""));
    QRegularExpressionMatchIterator i = stringExpression.globalMatch(text);
    while (i.hasNext()) {
        QRegularExpressionMatch match = i.next();
        setFormat(match.capturedStart(), match.capturedLength(), stringFormat);
    }
}
