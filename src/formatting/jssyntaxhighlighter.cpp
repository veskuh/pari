#include "jssyntaxhighlighter.h"

JsSyntaxHighlighter::JsSyntaxHighlighter(QTextDocument *parent, SyntaxTheme *theme)
    : QSyntaxHighlighter(parent),
      stringExpression(QStringLiteral("\"([^\"\\\\]|\\\\.)*\"|'([^'\\\\]|\\\\.)*'|`([^`\\\\]|\\\\.)*`")),
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
        QStringLiteral("\\bbreak\\b"), QStringLiteral("\\bcase\\b"),
        QStringLiteral("\\bcatch\\b"), QStringLiteral("\\bclass\\b"),
        QStringLiteral("\\bconst\\b"), QStringLiteral("\\bcontinue\\b"),
        QStringLiteral("\\bdebugger\\b"), QStringLiteral("\\bdefault\\b"),
        QStringLiteral("\\bdelete\\b"), QStringLiteral("\\bdo\\b"),
        QStringLiteral("\\belse\\b"), QStringLiteral("\\bexport\\b"),
        QStringLiteral("\\bextends\\b"), QStringLiteral("\\bfinally\\b"),
        QStringLiteral("\\bfor\\b"), QStringLiteral("\\bfunction\\b"),
        QStringLiteral("\\bif\\b"), QStringLiteral("\\bimport\\b"),
        QStringLiteral("\\bin\\b"), QStringLiteral("\\binstanceof\\b"),
        QStringLiteral("\\bnew\\b"), QStringLiteral("\\breturn\\b"),
        QStringLiteral("\\bsuper\\b"), QStringLiteral("\\bswitch\\b"),
        QStringLiteral("\\bthis\\b"), QStringLiteral("\\bthrow\\b"),
        QStringLiteral("\\btry\\b"), QStringLiteral("\\btypeof\\b"),
        QStringLiteral("\\bvar\\b"), QStringLiteral("\\bvoid\\b"),
        QStringLiteral("\\bwhile\\b"), QStringLiteral("\\bwith\\b"),
        QStringLiteral("\\byield\\b"), QStringLiteral("\\blet\\b"),
        QStringLiteral("\\bstatic\\b"), QStringLiteral("\\basync\\b"),
        QStringLiteral("\\bawait\\b"), QStringLiteral("\\bnull\\b"),
        QStringLiteral("\\btrue\\b"), QStringLiteral("\\bfalse\\b"),
        QStringLiteral("\\bundefined\\b")
    };
    for (const QString &pattern : keywordPatterns) {
        rule.pattern = QRegularExpression(pattern);
        rule.format = keywordFormat;
        highlightingRules.append(rule);
    }

    // Functions
    functionFormat.setForeground(m_theme->preprocessorColor); // Reusing preprocessor color for functions/methods
    rule.pattern = QRegularExpression(QStringLiteral("\\b[A-Za-z0-9_]+(?=\\()"));
    rule.format = functionFormat;
    highlightingRules.append(rule);

    // Numbers
    numberFormat.setForeground(m_theme->stringColor); // Reusing string color for numbers for now
    rule.pattern = QRegularExpression(QStringLiteral("\\b\\d+([.]\\d+)?\\b"));
    rule.format = numberFormat;
    highlightingRules.append(rule);

    // Single-line comments
    singleLineCommentFormat.setForeground(m_theme->commentColor);

    // Multi-line comments
    multiLineCommentFormat.setForeground(m_theme->commentColor);

    // Strings
    stringFormat.setForeground(m_theme->stringColor);
}

QList<JsSyntaxHighlighter::HighlightRange> JsSyntaxHighlighter::highlightLine(const QString &text) {
    QList<HighlightRange> ranges;

    // 1. Apply stateless rules
    for (const HighlightingRule &rule : highlightingRules) {
        QRegularExpressionMatchIterator matchIterator = rule.pattern.globalMatch(text);
        while (matchIterator.hasNext()) {
            QRegularExpressionMatch match = matchIterator.next();
            ranges.append({(int)match.capturedStart(), (int)match.capturedLength(), rule.format});
        }
    }

    // 2. Handle strings (supports ", ', and `)
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

    // 4. Handle multi-line comments (simple version for highlightLine)
    QRegularExpressionMatchIterator mlcIterator = mlcStart.globalMatch(text);
    while (mlcIterator.hasNext()) {
        QRegularExpressionMatch match = mlcIterator.next();
        int end = text.indexOf(mlcEnd, match.capturedStart() + 2);
        int len = (end == -1) ? text.length() - match.capturedStart() : end - match.capturedStart() + 2;
        ranges.append({(int)match.capturedStart(), len, multiLineCommentFormat});
    }

    return ranges;
}

void JsSyntaxHighlighter::highlightBlock(const QString &text) {
    QList<HighlightRange> ranges = highlightLine(text);
    for (const auto &range : ranges) {
        setFormat(range.start, range.length, range.format);
    }

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
