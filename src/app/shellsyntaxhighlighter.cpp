#include "shellsyntaxhighlighter.h"

ShellSyntaxHighlighter::ShellSyntaxHighlighter(QTextDocument *parent, SyntaxTheme *theme)
    : QSyntaxHighlighter(parent), m_theme(theme)
{
}

void ShellSyntaxHighlighter::highlightBlock(const QString &text)
{
    if (!m_theme) return;

    QTextCharFormat commentFormat;
    commentFormat.setForeground(m_theme->commentColor);

    QTextCharFormat stringFormat;
    stringFormat.setForeground(m_theme->stringColor);

    QRegularExpression expression(
        "(?<string>\"([^\"\\\\]|\\\\.)*\"|'[^']*')|"
        "(?<comment>#[^\n]*)"
    );

    QRegularExpressionMatchIterator it = expression.globalMatch(text);
    while (it.hasNext()) {
        QRegularExpressionMatch match = it.next();
        if (match.capturedStart("string") != -1) {
            setFormat(match.capturedStart("string"), match.capturedLength("string"), stringFormat);
        } else if (match.capturedStart("comment") != -1) {
            setFormat(match.capturedStart("comment"), match.capturedLength("comment"), commentFormat);
        }
    }
}
