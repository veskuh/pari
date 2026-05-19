#include "shellsyntaxhighlighter.h"
#include "syntaxtheme.h"

ShellSyntaxHighlighter::ShellSyntaxHighlighter(QTextDocument *parent, SyntaxTheme *theme)
    : QSyntaxHighlighter(parent), m_theme(theme) {
    if (m_theme) {
        commentFormat.setForeground(m_theme->commentColor);
        stringFormat.setForeground(m_theme->stringColor);
    }
}

void ShellSyntaxHighlighter::highlightBlock(const QString &text) {
    if (!m_theme)
        return;

    QRegularExpression expression("(?<string>\"([^\"\\\\]|\\\\.)*\"|'[^']*')|"
                                  "(?<comment>#[^\n]*)");

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
