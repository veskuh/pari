#include "swiftsyntaxhighlighter.h"

SwiftSyntaxHighlighter::SwiftSyntaxHighlighter(QTextDocument *parent, SyntaxTheme *theme)
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
        QStringLiteral("\\bclass\\b"), QStringLiteral("\\bfunc\\b"),
        QStringLiteral("\\bvar\\b"), QStringLiteral("\\blet\\b"),
        QStringLiteral("\\bif\\b"), QStringLiteral("\\belse\\b"),
        QStringLiteral("\\bfor\\b"), QStringLiteral("\\bwhile\\b"),
        QStringLiteral("\\breturn\\b"), QStringLiteral("\\bstruct\\b"),
        QStringLiteral("\\benum\\b"), QStringLiteral("\\bprotocol\\b"),
        QStringLiteral("\\bimport\\b"), QStringLiteral("\\bswitch\\b"),
        QStringLiteral("\\bcase\\b"), QStringLiteral("\\bbreak\\b"),
        QStringLiteral("\\bcontinue\\b"), QStringLiteral("\\bguard\\b"),
        QStringLiteral("\\bnil\\b"), QStringLiteral("\\btrue\\b"),
        QStringLiteral("\\bfalse\\b"), QStringLiteral("\\bself\\b"),
        QStringLiteral("\\binit\\b"), QStringLiteral("\\bdeinit\\b"),
        QStringLiteral("\\bextension\\b"), QStringLiteral("\\btypealias\\b"),
        QStringLiteral("\\bwhere\\b"), QStringLiteral("\\bas\\b"),
        QStringLiteral("\\bis\\b"), QStringLiteral("\\btry\\b"),
        QStringLiteral("\\bcatch\\b"), QStringLiteral("\\bthrow\\b"),
        QStringLiteral("\\bthrows\\b"), QStringLiteral("\\brethrows\\b"),
        QStringLiteral("\\bdefer\\b"), QStringLiteral("\\bdo\\b"),
        QStringLiteral("\\bfallthrough\\b"), QStringLiteral("\\bin\\b"),
        QStringLiteral("\\binout\\b"), QStringLiteral("\\boperator\\b"),
        QStringLiteral("\\bprecedencegroup\\b"), QStringLiteral("\\brepeat\\b")
    };
    for (const QString &pattern : keywordPatterns) {
        rule.pattern = QRegularExpression(pattern);
        rule.format = keywordFormat;
        highlightingRules.append(rule);
    }

    // Types (approximate)
    typeFormat.setForeground(m_theme->preprocessorColor); // Reusing preprocessor color for types
    QStringList typePatterns = {
        QStringLiteral("\\bString\\b"), QStringLiteral("\\bInt\\b"),
        QStringLiteral("\\bDouble\\b"), QStringLiteral("\\bFloat\\b"),
        QStringLiteral("\\bBool\\b"), QStringLiteral("\\bArray\\b"),
        QStringLiteral("\\bDictionary\\b"), QStringLiteral("\\bOptional\\b"),
        QStringLiteral("\\bSet\\b"), QStringLiteral("\\bAny\\b"),
        QStringLiteral("\\bAnyObject\\b"), QStringLiteral("\\bVoid\\b"),
        QStringLiteral("\\bUInt\\b"), QStringLiteral("\\bUInt8\\b"),
        QStringLiteral("\\bUInt16\\b"), QStringLiteral("\\bUInt32\\b"),
        QStringLiteral("\\bUInt64\\b"), QStringLiteral("\\bInt8\\b"),
        QStringLiteral("\\bInt16\\b"), QStringLiteral("\\bInt32\\b"),
        QStringLiteral("\\bInt64\\b")
    };
    for (const QString &pattern : typePatterns) {
        rule.pattern = QRegularExpression(pattern);
        rule.format = typeFormat;
        highlightingRules.append(rule);
    }

    // Attributes
    attributeFormat.setForeground(m_theme->preprocessorColor);
    rule.pattern = QRegularExpression(QStringLiteral("@\\w+"));
    rule.format = attributeFormat;
    highlightingRules.append(rule);

    // Single-line comments
    singleLineCommentFormat.setForeground(m_theme->commentColor);

    // Multi-line comments
    multiLineCommentFormat.setForeground(m_theme->commentColor);

    // Strings
    stringFormat.setForeground(m_theme->stringColor);
}

QList<SwiftSyntaxHighlighter::HighlightRange> SwiftSyntaxHighlighter::highlightLine(const QString &text) {
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

void SwiftSyntaxHighlighter::highlightBlock(const QString &text) {
    // Apply basic rules via highlightLine
    QList<HighlightRange> ranges = highlightLine(text);
    for (const auto &range : ranges) {
        setFormat(range.start, range.length, range.format);
    }

    // Multi-line comment state handling
    setCurrentBlockState(Normal);
    int startIndex = 0;
    bool startedInComment = false;

    if (previousBlockState() != InComment) {
        startIndex = text.indexOf(commentStart);
    } else {
        startedInComment = true;
    }

    while (startIndex >= 0) {
        int searchStart = startedInComment ? startIndex : startIndex + 2;
        int endIndex = text.indexOf(commentEnd, searchStart);
        int commentLength;
        if (endIndex == -1) {
            setCurrentBlockState(InComment);
            commentLength = text.length() - startIndex;
        } else {
            commentLength = endIndex - startIndex + 2;
        }
        setFormat(startIndex, commentLength, multiLineCommentFormat);
        startIndex = text.indexOf(commentStart, startIndex + commentLength);
        startedInComment = false;
    }
}
