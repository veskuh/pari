#include "kotlinsyntaxhighlighter.h"
#include "syntaxtheme.h"
#include <utility>

KotlinSyntaxHighlighter::KotlinSyntaxHighlighter(QTextDocument *parent, SyntaxTheme *theme)
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

    // Kotlin Keywords
    keywordFormat.setForeground(m_theme->keywordColor);
    QStringList keywordPatterns = {
        QStringLiteral("\\bas\\b"), QStringLiteral("\\bas\\?\\b"), QStringLiteral("\\bbreak\\b"),
        QStringLiteral("\\bclass\\b"), QStringLiteral("\\bcontinue\\b"), QStringLiteral("\\bdo\\b"),
        QStringLiteral("\\belse\\b"), QStringLiteral("\\bfalse\\b"), QStringLiteral("\\bfor\\b"),
        QStringLiteral("\\bfun\\b"), QStringLiteral("\\bif\\b"), QStringLiteral("\\bin\\b"),
        QStringLiteral("\\b!in\\b"), QStringLiteral("\\binterface\\b"), QStringLiteral("\\bis\\b"),
        QStringLiteral("\\b!is\\b"), QStringLiteral("\\bnull\\b"), QStringLiteral("\\bobject\\b"),
        QStringLiteral("\\bpackage\\b"), QStringLiteral("\\breturn\\b"), QStringLiteral("\\bsuper\\b"),
        QStringLiteral("\\bthis\\b"), QStringLiteral("\\bthrow\\b"), QStringLiteral("\\btrue\\b"),
        QStringLiteral("\\btry\\b"), QStringLiteral("\\btypealias\\b"), QStringLiteral("\\btypeof\\b"),
        QStringLiteral("\\bval\\b"), QStringLiteral("\\bvar\\b"), QStringLiteral("\\bwhen\\b"),
        QStringLiteral("\\bwhile\\b"),
        // Modifiers & Soft keywords
        QStringLiteral("\\babstract\\b"), QStringLiteral("\\bannotation\\b"), QStringLiteral("\\bcompanion\\b"),
        QStringLiteral("\\bconst\\b"), QStringLiteral("\\bconstructor\\b"), QStringLiteral("\\bcrossinline\\b"),
        QStringLiteral("\\bdata\\b"), QStringLiteral("\\benum\\b"), QStringLiteral("\\bexpect\\b"),
        QStringLiteral("\\bexternal\\b"), QStringLiteral("\\bfinal\\b"), QStringLiteral("\\bfield\\b"),
        QStringLiteral("\\bfile\\b"), QStringLiteral("\\bget\\b"), QStringLiteral("\\binner\\b"),
        QStringLiteral("\\binternal\\b"), QStringLiteral("\\binline\\b"), QStringLiteral("\\bnoinline\\b"),
        QStringLiteral("\\blateinit\\b"), QStringLiteral("\\bopen\\b"), QStringLiteral("\\boperator\\b"),
        QStringLiteral("\\bout\\b"), QStringLiteral("\\boverride\\b"), QStringLiteral("\\bparam\\b"),
        QStringLiteral("\\bprivate\\b"), QStringLiteral("\\bprotected\\b"), QStringLiteral("\\bpublic\\b"),
        QStringLiteral("\\breceiver\\b"), QStringLiteral("\\breified\\b"), QStringLiteral("\\bsealed\\b"),
        QStringLiteral("\\bset\\b"), QStringLiteral("\\bsetparam\\b"), QStringLiteral("\\bsuspend\\b"),
        QStringLiteral("\\btailrec\\b"), QStringLiteral("\\bvararg\\b")
    };
    for (const QString &pattern : keywordPatterns) {
        rule.pattern = QRegularExpression(pattern);
        rule.format = keywordFormat;
        highlightingRules.append(rule);
    }

    // Annotations
    annotationFormat.setForeground(m_theme->preprocessorColor);
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

QList<KotlinSyntaxHighlighter::HighlightRange> KotlinSyntaxHighlighter::highlightLine(const QString &text) {
    QList<HighlightRange> ranges;

    // 1. Apply stateless rules
    for (const HighlightingRule &rule : std::as_const(highlightingRules)) {
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

void KotlinSyntaxHighlighter::highlightBlock(const QString &text) {
    QList<HighlightRange> ranges = highlightLine(text);
    for (const auto &range : std::as_const(ranges)) {
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
