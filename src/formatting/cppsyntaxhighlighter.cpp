#include "cppsyntaxhighlighter.h"
#include "syntaxtheme.h"

CppSyntaxHighlighter::CppSyntaxHighlighter(QTextDocument *parent, SyntaxTheme *theme)
    : QSyntaxHighlighter(parent),
      stringExpression(QStringLiteral("\"([^\"\\\\]|\\\\.)*\"")),
      singleLineCommentExpression(QStringLiteral("//[^\n]*")),
      mlcStart(QStringLiteral("/\\*")),
      mlcEnd(QStringLiteral("\\*/")),
      commentStart(QStringLiteral("/\\*")),
      commentEnd(QStringLiteral("\\*/")),
      m_theme(theme) {
    HighlightingRule rule;

    if (!m_theme) {
        return;
    }

    // Keywords
    keywordFormat.setForeground(m_theme->keywordColor);
    QStringList keywordPatterns = {QStringLiteral("\\bclass\\b"),   QStringLiteral("\\bint\\b"),
                                   QStringLiteral("\\breturn\\b"),  QStringLiteral("\\bif\\b"),
                                   QStringLiteral("\\belse\\b"),    QStringLiteral("\\bfor\\b"),
                                   QStringLiteral("\\bwhile\\b"),   QStringLiteral("\\bpublic\\b"),
                                   QStringLiteral("\\bprivate\\b"), QStringLiteral("\\busing\\b")};
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

QList<CppSyntaxHighlighter::HighlightRange> CppSyntaxHighlighter::highlightLine(const QString &text) {
    QList<HighlightRange> ranges;

    // 1. Apply stateless rules (keywords, includes, macros)
    for (const HighlightingRule &rule : highlightingRules) {
        QRegularExpressionMatchIterator matchIterator = rule.pattern.globalMatch(text);
        while (matchIterator.hasNext()) {
            QRegularExpressionMatch match = matchIterator.next();
            ranges.append({(int)match.capturedStart(), (int)match.capturedLength(), rule.format});
        }
    }

    // 2. Handle strings
    QRegularExpressionMatchIterator stringIterator = stringExpression.globalMatch(text);
    while (stringIterator.hasNext()) {
        QRegularExpressionMatch match = stringIterator.next();
        ranges.append({(int)match.capturedStart(), (int)match.capturedLength(), stringFormat});
    }

    // 3. Handle single-line comments
    QRegularExpressionMatchIterator slcIterator = singleLineCommentExpression.globalMatch(text);
    while (slcIterator.hasNext()) {
        QRegularExpressionMatch match = slcIterator.next();
        ranges.append({(int)match.capturedStart(), (int)match.capturedLength(), singleLineCommentFormat});
    }

    // 4. Handle multi-line comments (simple version for highlightLine, doesn't handle state)
    QRegularExpressionMatchIterator mlcIterator = mlcStart.globalMatch(text);
    while (mlcIterator.hasNext()) {
        QRegularExpressionMatch match = mlcIterator.next();
        int end = text.indexOf(mlcEnd, match.capturedStart() + 2);
        int len = (end == -1) ? text.length() - match.capturedStart() : end - match.capturedStart() + 2;
        ranges.append({(int)match.capturedStart(), len, multiLineCommentFormat});
    }

    return ranges;
}

void CppSyntaxHighlighter::highlightBlock(const QString &text) {
    // Apply basic rules via highlightLine
    QList<HighlightRange> ranges = highlightLine(text);
    for (const auto &range : ranges) {
        setFormat(range.start, range.length, range.format);
    }

    // Multi-line comment state handling (needs to remain in highlightBlock for QSyntaxHighlighter)
    setCurrentBlockState(Normal);
    int startIndex = 0;

    if (previousBlockState() != InComment) {
        startIndex = text.indexOf(commentStart);
    }

    while (startIndex >= 0) {
        int endIndex = text.indexOf(commentEnd, startIndex + 2);
        int commentLength;
        if (endIndex == -1) {
            setCurrentBlockState(InComment);
            commentLength = text.length() - startIndex;
        } else {
            commentLength = endIndex - startIndex + 2;
        }
        setFormat(startIndex, commentLength, multiLineCommentFormat);
        startIndex = text.indexOf(commentStart, startIndex + commentLength);
    }
}
