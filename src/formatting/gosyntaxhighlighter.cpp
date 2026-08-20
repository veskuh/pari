#include "gosyntaxhighlighter.h"
#include "syntaxtheme.h"
#include <utility>

GoSyntaxHighlighter::GoSyntaxHighlighter(QTextDocument *parent, SyntaxTheme *theme)
    : QSyntaxHighlighter(parent),
      stringExpression(QStringLiteral("\"([^\"\\\\]|\\\\.)*\"")),
      rawStringStart(QStringLiteral("`")),
      rawStringEnd(QStringLiteral("`")),
      singleLineCommentExpression(QStringLiteral("//[^\n]*")),
      mlcStart(QStringLiteral("/\\*")),
      mlcEnd(QStringLiteral("\\*/")),
      m_theme(theme) {
    HighlightingRule rule;

    if (!m_theme) {
        return;
    }

    // Keywords
    keywordFormat.setForeground(m_theme->keywordColor);
    QStringList keywordPatterns = {
        QStringLiteral("\\bbreak\\b"), QStringLiteral("\\bdefault\\b"), QStringLiteral("\\bfunc\\b"),
        QStringLiteral("\\binterface\\b"), QStringLiteral("\\bselect\\b"), QStringLiteral("\\bcase\\b"),
        QStringLiteral("\\bdefer\\b"), QStringLiteral("\\bgo\\b"), QStringLiteral("\\bmap\\b"),
        QStringLiteral("\\bstruct\\b"), QStringLiteral("\\bchan\\b"), QStringLiteral("\\belse\\b"),
        QStringLiteral("\\bgoto\\b"), QStringLiteral("\\bpackage\\b"), QStringLiteral("\\bswitch\\b"),
        QStringLiteral("\\bconst\\b"), QStringLiteral("\\bfallthrough\\b"), QStringLiteral("\\bif\\b"),
        QStringLiteral("\\brange\\b"), QStringLiteral("\\btype\\b"), QStringLiteral("\\bcontinue\\b"),
        QStringLiteral("\\bfor\\b"), QStringLiteral("\\bimport\\b"), QStringLiteral("\\breturn\\b"),
        QStringLiteral("\\bvar\\b")
    };
    for (const QString &pattern : keywordPatterns) {
        rule.pattern = QRegularExpression(pattern);
        rule.format = keywordFormat;
        highlightingRules.append(rule);
    }

    // Types
    typeFormat.setForeground(m_theme->keywordColor); 
    QStringList typePatterns = {
        QStringLiteral("\\bbool\\b"), QStringLiteral("\\bstring\\b"), QStringLiteral("\\bint\\b"),
        QStringLiteral("\\bint8\\b"), QStringLiteral("\\bint16\\b"), QStringLiteral("\\bint32\\b"),
        QStringLiteral("\\bint64\\b"), QStringLiteral("\\buint\\b"), QStringLiteral("\\buint8\\b"),
        QStringLiteral("\\buint16\\b"), QStringLiteral("\\buint32\\b"), QStringLiteral("\\buint64\\b"),
        QStringLiteral("\\buintptr\\b"), QStringLiteral("\\bbyte\\b"), QStringLiteral("\\brune\\b"),
        QStringLiteral("\\bfloat32\\b"), QStringLiteral("\\bfloat64\\b"), QStringLiteral("\\bcomplex64\\b"),
        QStringLiteral("\\bcomplex128\\b"), QStringLiteral("\\berror\\b")
    };
    for (const QString &pattern : typePatterns) {
        rule.pattern = QRegularExpression(pattern);
        rule.format = typeFormat;
        highlightingRules.append(rule);
    }

    // Constants
    constantFormat.setForeground(m_theme->keywordColor);
    QStringList constantPatterns = {
        QStringLiteral("\\btrue\\b"), QStringLiteral("\\bfalse\\b"), QStringLiteral("\\biota\\b"),
        QStringLiteral("\\bnil\\b")
    };
    for (const QString &pattern : constantPatterns) {
        rule.pattern = QRegularExpression(pattern);
        rule.format = constantFormat;
        highlightingRules.append(rule);
    }

    // Single-line comments
    singleLineCommentFormat.setForeground(m_theme->commentColor);

    // Multi-line comments
    multiLineCommentFormat.setForeground(m_theme->commentColor);

    // Strings
    stringFormat.setForeground(m_theme->stringColor);
}

QList<GoSyntaxHighlighter::HighlightRange> GoSyntaxHighlighter::highlightLine(const QString &text) {
    QList<HighlightRange> ranges;

    // 1. Apply stateless rules (keywords, types, constants)
    for (const HighlightingRule &rule : std::as_const(highlightingRules)) {
        QRegularExpressionMatchIterator matchIterator = rule.pattern.globalMatch(text);
        while (matchIterator.hasNext()) {
            QRegularExpressionMatch match = matchIterator.next();
            ranges.append({(int)match.capturedStart(), (int)match.capturedLength(), rule.format});
        }
    }

    // 2. Handle strings (interpreted)
    QRegularExpressionMatchIterator stringIterator = stringExpression.globalMatch(text);
    while (stringIterator.hasNext()) {
        QRegularExpressionMatch match = stringIterator.next();
        ranges.append({(int)match.capturedStart(), (int)match.capturedLength(), stringFormat});
    }

    // 3. Handle raw strings (simple version for highlightLine)
    int start = text.indexOf(rawStringStart);
    while (start >= 0) {
        int end = text.indexOf(rawStringEnd, start + 1);
        int len = (end == -1) ? text.length() - start : end - start + 1;
        ranges.append({start, len, stringFormat});
        if (end == -1) break;
        start = text.indexOf(rawStringStart, end + 1);
    }

    // 4. Handle single-line comments
    QRegularExpressionMatchIterator slcIterator = singleLineCommentExpression.globalMatch(text);
    while (slcIterator.hasNext()) {
        QRegularExpressionMatch match = slcIterator.next();
        ranges.append({(int)match.capturedStart(), (int)match.capturedLength(), singleLineCommentFormat});
    }

    // 5. Handle multi-line comments (simple version for highlightLine)
    QRegularExpressionMatchIterator mlcIterator = mlcStart.globalMatch(text);
    while (mlcIterator.hasNext()) {
        QRegularExpressionMatch match = mlcIterator.next();
        int end = text.indexOf(mlcEnd, match.capturedStart() + 2);
        int len = (end == -1) ? text.length() - match.capturedStart() : end - match.capturedStart() + 2;
        ranges.append({(int)match.capturedStart(), len, multiLineCommentFormat});
    }

    return ranges;
}

void GoSyntaxHighlighter::highlightBlock(const QString &text) {
    QList<HighlightRange> ranges = highlightLine(text);
    for (const auto &range : std::as_const(ranges)) {
        setFormat(range.start, range.length, range.format);
    }

    int currentState = Normal;
    if (previousBlockState() == InComment) currentState = InComment;
    else if (previousBlockState() == InRawString) currentState = InRawString;

    int startIndex = 0;
    while (startIndex < text.length()) {
        if (currentState == InComment) {
            int endIndex = text.indexOf(mlcEnd, startIndex);
            if (endIndex == -1) {
                setFormat(startIndex, text.length() - startIndex, multiLineCommentFormat);
                break;
            } else {
                setFormat(startIndex, endIndex - startIndex + 2, multiLineCommentFormat);
                startIndex = endIndex + 2;
                currentState = Normal;
            }
        } else if (currentState == InRawString) {
            int endIndex = text.indexOf(rawStringEnd, startIndex);
            if (endIndex == -1) {
                setFormat(startIndex, text.length() - startIndex, stringFormat);
                break;
            } else {
                setFormat(startIndex, endIndex - startIndex + 1, stringFormat);
                startIndex = endIndex + 1;
                currentState = Normal;
            }
        } else {
            int mlcIdx = text.indexOf(mlcStart, startIndex);
            int rawIdx = text.indexOf(rawStringStart, startIndex);

            if (mlcIdx == -1 && rawIdx == -1) break;

            if (mlcIdx != -1 && (rawIdx == -1 || mlcIdx < rawIdx)) {
                startIndex = mlcIdx;
                currentState = InComment;
            } else {
                startIndex = rawIdx;
                currentState = InRawString;
            }
            
            // Re-evaluating current state immediately
            if (currentState == InComment) {
                int endIndex = text.indexOf(mlcEnd, startIndex + 2);
                if (endIndex == -1) {
                    setFormat(startIndex, text.length() - startIndex, multiLineCommentFormat);
                    currentState = InComment;
                    break;
                } else {
                    setFormat(startIndex, endIndex - startIndex + 2, multiLineCommentFormat);
                    startIndex = endIndex + 2;
                    currentState = Normal;
                }
            } else if (currentState == InRawString) {
                int endIndex = text.indexOf(rawStringEnd, startIndex + 1);
                if (endIndex == -1) {
                    setFormat(startIndex, text.length() - startIndex, stringFormat);
                    currentState = InRawString;
                    break;
                } else {
                    setFormat(startIndex, endIndex - startIndex + 1, stringFormat);
                    startIndex = endIndex + 1;
                    currentState = Normal;
                }
            }
        }
    }
    setCurrentBlockState(currentState);
}
