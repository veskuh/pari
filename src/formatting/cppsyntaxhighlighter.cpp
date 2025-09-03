#include "cppsyntaxhighlighter.h"

CppSyntaxHighlighter::CppSyntaxHighlighter(QTextDocument *parent, SyntaxTheme *theme)
    : QSyntaxHighlighter(parent), m_theme(theme)
{
    HighlightingRule rule;

    if (!m_theme) {
        return;
    }

    // Keywords
    keywordFormat.setForeground(m_theme->keywordColor);
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
    includeFormat.setForeground(m_theme->preprocessorColor); // Using preprocessor color for includes
    rule.pattern = QRegularExpression(QStringLiteral("^\\s*#include\\s*[<\"][^>\"]*[\">]"));
    rule.format = includeFormat;
    highlightingRules.append(rule);

    // Macros
    macroFormat.setForeground(m_theme->preprocessorColor); // Using preprocessor color for macros
    rule.pattern = QRegularExpression(QStringLiteral("^\\s*#define.*"));
    rule.format = macroFormat;
    highlightingRules.append(rule);

    // Single-line comments
    singleLineCommentFormat.setForeground(m_theme->commentColor);

    // Multi-line comments
    multiLineCommentFormat.setForeground(m_theme->commentColor);

    // Strings
    stringFormat.setForeground(m_theme->stringColor);
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
