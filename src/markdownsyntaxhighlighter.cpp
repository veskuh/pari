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
    int state = previousBlockState();
    if (state == -1) state = 0;

    int offset = 0;

    if (state == 1) { // In a code block
        int endIndex = text.indexOf(codeBlockEndExpression);
        if (endIndex == -1) { // Block continues
            setFormat(0, text.length(), codeBlockFormat);
            setCurrentBlockState(1);
            return;
        } else { // Block ends
            setFormat(0, endIndex + 3, codeBlockFormat);
            offset = endIndex + 3;
            state = 0;
        }
    }

    setCurrentBlockState(state);

    // Apply single-line rules to the rest of the line
    int searchOffset = offset;
    while (searchOffset < text.length()) {
        int startIndex = text.indexOf(codeBlockStartExpression, searchOffset);
        if (startIndex == -1) {
            applyNormalRules(text, searchOffset, text.length() - searchOffset);
            break;
        }

        applyNormalRules(text, searchOffset, startIndex - searchOffset);

        int endIndex = text.indexOf(codeBlockEndExpression, startIndex + 3);
        if (endIndex == -1) {
            setFormat(startIndex, text.length() - startIndex, codeBlockFormat);
            setCurrentBlockState(1);
            break;
        }

        setFormat(startIndex, endIndex - startIndex + 3, codeBlockFormat);
        searchOffset = endIndex + 3;
    }
}

void MarkdownSyntaxHighlighter::applyNormalRules(const QString &text, int offset, int length)
{
    if (length <= 0) return;
    QString subString = text.mid(offset, length);
    for (const HighlightingRule &rule : highlightingRules) {
        QRegularExpressionMatchIterator matchIterator = rule.pattern.globalMatch(subString);
        while (matchIterator.hasNext()) {
            QRegularExpressionMatch match = matchIterator.next();
            setFormat(offset + match.capturedStart(), match.capturedLength(), rule.format);
        }
    }
}
