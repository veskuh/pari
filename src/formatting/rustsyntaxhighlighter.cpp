#include "rustsyntaxhighlighter.h"
#include "syntaxtheme.h"

RustSyntaxHighlighter::RustSyntaxHighlighter(QTextDocument *parent, SyntaxTheme *theme)
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
    QStringList keywordPatterns = {
        QStringLiteral("\\bas\\b"), QStringLiteral("\\basync\\b"), QStringLiteral("\\bawait\\b"),
        QStringLiteral("\\bbreak\\b"), QStringLiteral("\\bconst\\b"), QStringLiteral("\\bcontinue\\b"),
        QStringLiteral("\\bcrate\\b"), QStringLiteral("\\bdyn\\b"), QStringLiteral("\\belse\\b"),
        QStringLiteral("\\benum\\b"), QStringLiteral("\\bextern\\b"), QStringLiteral("\\bfalse\\b"),
        QStringLiteral("\\bfn\\b"), QStringLiteral("\\bfor\\b"), QStringLiteral("\\bif\\b"),
        QStringLiteral("\\bimpl\\b"), QStringLiteral("\\bin\\b"), QStringLiteral("\\blet\\b"),
        QStringLiteral("\\bloop\\b"), QStringLiteral("\\bmatch\\b"), QStringLiteral("\\bmod\\b"),
        QStringLiteral("\\bmove\\b"), QStringLiteral("\\bmut\\b"), QStringLiteral("\\bpub\\b"),
        QStringLiteral("\\bref\\b"), QStringLiteral("\\breturn\\b"), QStringLiteral("\\bself\\b"),
        QStringLiteral("\\bSelf\\b"), QStringLiteral("\\bstatic\\b"), QStringLiteral("\\bstruct\\b"),
        QStringLiteral("\\bsuper\\b"), QStringLiteral("\\btrait\\b"), QStringLiteral("\\btrue\\b"),
        QStringLiteral("\\btype\\b"), QStringLiteral("\\bunion\\b"), QStringLiteral("\\bunsafe\\b"),
        QStringLiteral("\\buse\\b"), QStringLiteral("\\bwhere\\b"), QStringLiteral("\\bwhile\\b")
    };
    for (const QString &pattern : keywordPatterns) {
        rule.pattern = QRegularExpression(pattern);
        rule.format = keywordFormat;
        highlightingRules.append(rule);
    }

    // Types
    typeFormat.setForeground(m_theme->keywordColor); // Or use a different color if available
    QStringList typePatterns = {
        QStringLiteral("\\bbool\\b"), QStringLiteral("\\bchar\\b"), QStringLiteral("\\bf32\\b"),
        QStringLiteral("\\bf64\\b"), QStringLiteral("\\bi8\\b"), QStringLiteral("\\bi16\\b"),
        QStringLiteral("\\bi32\\b"), QStringLiteral("\\bi64\\b"), QStringLiteral("\\bi128\\b"),
        QStringLiteral("\\bisize\\b"), QStringLiteral("\\bstr\\b"), QStringLiteral("\\bu8\\b"),
        QStringLiteral("\\bu16\\b"), QStringLiteral("\\bu32\\b"), QStringLiteral("\\bu64\\b"),
        QStringLiteral("\\bu128\\b"), QStringLiteral("\\busize\\b")
    };
    for (const QString &pattern : typePatterns) {
        rule.pattern = QRegularExpression(pattern);
        rule.format = typeFormat;
        highlightingRules.append(rule);
    }

    // Attributes
    attributeFormat.setForeground(m_theme->preprocessorColor);
    rule.pattern = QRegularExpression(QStringLiteral("#\\[.*\\]"));
    rule.format = attributeFormat;
    highlightingRules.append(rule);

    // Single-line comments
    singleLineCommentFormat.setForeground(m_theme->commentColor);

    // Multi-line comments
    multiLineCommentFormat.setForeground(m_theme->commentColor);

    // Strings
    stringFormat.setForeground(m_theme->stringColor);
}

QList<RustSyntaxHighlighter::HighlightRange> RustSyntaxHighlighter::highlightLine(const QString &text) {
    QList<HighlightRange> ranges;

    // 1. Apply stateless rules (keywords, types, attributes)
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

    // 4. Handle multi-line comments
    QRegularExpressionMatchIterator mlcIterator = mlcStart.globalMatch(text);
    while (mlcIterator.hasNext()) {
        QRegularExpressionMatch match = mlcIterator.next();
        int end = text.indexOf(mlcEnd, match.capturedStart() + 2);
        int len = (end == -1) ? text.length() - match.capturedStart() : end - match.capturedStart() + 2;
        ranges.append({(int)match.capturedStart(), len, multiLineCommentFormat});
    }

    return ranges;
}

void RustSyntaxHighlighter::highlightBlock(const QString &text) {
    QList<HighlightRange> ranges = highlightLine(text);
    for (const auto &range : ranges) {
        setFormat(range.start, range.length, range.format);
    }

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
