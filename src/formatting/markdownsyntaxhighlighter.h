#ifndef MARKDOWNSYNTAXHIGHLIGHTER_H
#define MARKDOWNSYNTAXHIGHLIGHTER_H

#include <QSyntaxHighlighter>
#include <QRegularExpression>
#include <QTextCharFormat>
#include <QVector>
#include "syntaxtheme.h"

class MarkdownSyntaxHighlighter : public QSyntaxHighlighter
{
    Q_OBJECT

public:
    explicit MarkdownSyntaxHighlighter(QTextDocument *parent = nullptr, SyntaxTheme *theme = nullptr);

protected:
    void highlightBlock(const QString &text) override;

private:
    void applyNormalRules(const QString &text, int offset, int length);

    struct HighlightingRule
    {
        QRegularExpression pattern;
        QTextCharFormat format;
    };
    QVector<HighlightingRule> highlightingRules;

    QRegularExpression codeBlockStartExpression;
    QRegularExpression codeBlockEndExpression;

    QTextCharFormat headerFormat;
    QTextCharFormat boldFormat;
    QTextCharFormat italicFormat;
    QTextCharFormat linkFormat;
    QTextCharFormat imageFormat;
    QTextCharFormat blockquoteFormat;
    QTextCharFormat codeBlockFormat;
    QTextCharFormat inlineCodeFormat;
    QTextCharFormat commentFormat;

    SyntaxTheme *m_theme;
};

#endif // MARKDOWNSYNTAXHIGHLIGHTER_H
