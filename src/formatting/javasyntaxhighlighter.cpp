#include "javasyntaxhighlighter.h"
#include "syntaxtheme.h"

JavaSyntaxHighlighter::JavaSyntaxHighlighter(QTextDocument *parent, SyntaxTheme *theme)
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

    // Java Keywords
    keywordFormat.setForeground(m_theme->keywordColor);
    QStringList keywordPatterns = {
        QStringLiteral("\\babstract\\b"), QStringLiteral("\\bassert\\b"), QStringLiteral("\\bboolean\\b"),
        QStringLiteral("\\bbreak\\b"), QStringLiteral("\\bbyte\\b"), QStringLiteral("\\bcase\\b"),
        QStringLiteral("\\bcatch\\b"), QStringLiteral("\\bchar\\b"), QStringLiteral("\\bclass\\b"),
        QStringLiteral("\\bconst\\b"), QStringLiteral("\\bcontinue\\b"), QStringLiteral("\\bdefault\\b"),
        QStringLiteral("\\bdo\\b"), QStringLiteral("\\bdouble\\b"), QStringLiteral("\\belse\\b"),
        QStringLiteral("\\benum\\b"), QStringLiteral("\\bextends\\b"), QStringLiteral("\\bfinal\\b"),
        QStringLiteral("\\bfinally\\b"), QStringLiteral("\\bfloat\\b"), QStringLiteral("\\bfor\\b"),
        QStringLiteral("\\bgoto\\b"), QStringLiteral("\\bif\\b"), QStringLiteral("\\bimplements\\b"),
        QStringLiteral("\\bimport\\b"), QStringLiteral("\\binstanceof\\b"), QStringLiteral("\\bint\\b"),
        QStringLiteral("\\binterface\\b"), QStringLiteral("\\blong\\b"), QStringLiteral("\\bnative\\b"),
        QStringLiteral("\\bnew\\b"), QStringLiteral("\\bpackage\\b"), QStringLiteral("\\bprivate\\b"),
        QStringLiteral("\\bprotected\\b"), QStringLiteral("\\bpublic\\b"), QStringLiteral("\\breturn\\b"),
        QStringLiteral("\\bshort\\b"), QStringLiteral("\\bstatic\\b"), QStringLiteral("\\bstrictfp\\b"),
        QStringLiteral("\\bsuper\\b"), QStringLiteral("\\bswitch\\b"), QStringLiteral("\\bsynchronized\\b"),
        QStringLiteral("\\bthis\\b"), QStringLiteral("\\bthrow\\b"), QStringLiteral("\\bthrows\\b"),
        QStringLiteral("\\btransient\\b"), QStringLiteral("\\btry\\b"), QStringLiteral("\\bvoid\\b"),
        QStringLiteral("\\bvolatile\\b"), QStringLiteral("\\bwhile\\b"), QStringLiteral("\\bvar\\b"),
        QStringLiteral("\\brecord\\b"), QStringLiteral("\\byield\\b"), QStringLiteral("\\bsealed\\b"),
        QStringLiteral("\\bnon-sealed\\b"), QStringLiteral("\\bpermits\\b")
    };
    for (const QString &pattern : keywordPatterns) {
        rule.pattern = QRegularExpression(pattern);
        rule.format = keywordFormat;
        highlightingRules.append(rule);
    }

    // Annotations
    annotationFormat.setForeground(m_theme->preprocessorColor); // Using preprocessor color for annotations
    rule.pattern = QRegularExpression(QStringLiteral("@\\w+"));
    rule.format = annotationFormat;
    highlightingRules.append(rule);

    // Single-line comments
    singleLineCommentFormat.setForeground(m_theme->commentColor);

    // Multi-line comments
    multiLineCommentFormat.setForeground(m_theme->commentColor);

    // Strings
    stringFormat.setForeground(m_theme->stringColor);
}

QList<JavaSyntaxHighlighter::HighlightRange> JavaSyntaxHighlighter::highlightLine(const QString &text) {
    QList<HighlightRange> ranges;

    // 1. Apply stateless rules (keywords, annotations)
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

void JavaSyntaxHighlighter::highlightBlock(const QString &text) {
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
