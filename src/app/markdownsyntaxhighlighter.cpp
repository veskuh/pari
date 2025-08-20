#include "markdownsyntaxhighlighter.h"

MarkdownSyntaxHighlighter::MarkdownSyntaxHighlighter(QTextDocument *parent, SyntaxTheme *theme)
    : QSyntaxHighlighter(parent), m_theme(theme)
{
    if (!m_theme) {
        return;
    }

    HighlightingRule rule;

    // Headers (e.g., #, ##, ###)
    headerFormat.setForeground(m_theme->keywordColor);
    headerFormat.setFontWeight(QFont::Bold);
    rule.pattern = QRegularExpression(QStringLiteral("^(#+)\\s+.*"));
    rule.format = headerFormat;
    highlightingRules.append(rule);

    // Bold (e.g., **text** or __text__)
    boldFormat.setFontWeight(QFont::Bold);
    rule.pattern = QRegularExpression(QStringLiteral("(\\*\\*|__)(.+?)\\1"));
    rule.format = boldFormat;
    highlightingRules.append(rule);

    // Italic (e.g., *text* or _text_)
    italicFormat.setFontItalic(true);
    rule.pattern = QRegularExpression(QStringLiteral("(?<![*_])([*_])(?!\\1)(.+?)(?<!\\1)\\1(?!\\1)"));
    rule.format = italicFormat;
    highlightingRules.append(rule);

    // Links (e.g., [text](url))
    linkFormat.setForeground(m_theme->stringColor);
    linkFormat.setFontUnderline(true);
    rule.pattern = QRegularExpression(QStringLiteral("\\[([^\\]]+)\\]\\(([^\\)]+)\\)"));
    rule.format = linkFormat;
    highlightingRules.append(rule);

    // Images (e.g., ![alt](src))
    imageFormat.setForeground(m_theme->stringColor);
    rule.pattern = QRegularExpression(QStringLiteral("!\\[([^\\]]*)\\]\\(([^\\)]+)\\)"));
    rule.format = imageFormat;
    highlightingRules.append(rule);

    // Blockquotes (e.g., > text)
    blockquoteFormat.setForeground(m_theme->commentColor);
    blockquoteFormat.setFontItalic(true);
    rule.pattern = QRegularExpression(QStringLiteral("^>\\s+.*"));
    rule.format = blockquoteFormat;
    highlightingRules.append(rule);

    // Inline code (e.g., `code`)
    inlineCodeFormat.setForeground(m_theme->stringColor);
    rule.pattern = QRegularExpression(QStringLiteral("`([^`]+)`"));
    rule.format = inlineCodeFormat;
    highlightingRules.append(rule);

    // Code blocks (fenced with ```)
    codeBlockFormat.setForeground(m_theme->stringColor);
    codeBlockStartExpression = QRegularExpression(QStringLiteral("```"));
    codeBlockEndExpression = QRegularExpression(QStringLiteral("```"));

    // Comments
    commentFormat.setForeground(m_theme->commentColor);
    HighlightingRule commentRule;
    commentRule.pattern = QRegularExpression(QStringLiteral("<!--(.*?)-->"));
    commentRule.format = commentFormat;
    highlightingRules.append(commentRule);
}

void MarkdownSyntaxHighlighter::highlightBlock(const QString &text)
{
    for (const HighlightingRule &rule : highlightingRules) {
        QRegularExpressionMatchIterator matchIterator = rule.pattern.globalMatch(text);
        while (matchIterator.hasNext()) {
            QRegularExpressionMatch match = matchIterator.next();
            setFormat(match.capturedStart(), match.capturedLength(), rule.format);
        }
    }

    setCurrentBlockState(0);

    int startIndex = 0;
    if (previousBlockState() != 1)
        startIndex = text.indexOf(codeBlockStartExpression);

    while (startIndex >= 0) {
        QRegularExpressionMatch endMatch;
        int endIndex = text.indexOf(codeBlockEndExpression, startIndex + 3);
        int commentLength;
        if (endIndex == -1) {
            setCurrentBlockState(1);
            commentLength = text.length() - startIndex;
        } else {
            commentLength = endIndex - startIndex + 3;
        }
        setFormat(startIndex, commentLength, codeBlockFormat);
        startIndex = text.indexOf(codeBlockStartExpression, startIndex + commentLength);
    }
}
