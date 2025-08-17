#ifndef CPPSYNTAXHIGHLIGHTER_H
#define CPPSYNTAXHIGHLIGHTER_H

#include <QSyntaxHighlighter>
#include <QRegularExpression>
#include <QTextCharFormat>
#include <QVector>
#include "settings.h"

class CppSyntaxHighlighter : public QSyntaxHighlighter
{
    Q_OBJECT

public:
    explicit CppSyntaxHighlighter(QTextDocument *parent = nullptr, SyntaxTheme *theme = nullptr);

protected:
    void highlightBlock(const QString &text) override;

private:
    enum BlockState {
        Normal = 0,
        InComment = 1,
        InString = 2
    };

    struct HighlightingRule
    {
        QRegularExpression pattern;
        QTextCharFormat format;
    };
    QVector<HighlightingRule> highlightingRules;

    QRegularExpression multiLineCommentStartExpression;
    QRegularExpression multiLineCommentEndExpression;

    QTextCharFormat keywordFormat;
    QTextCharFormat includeFormat;
    QTextCharFormat macroFormat;
    QTextCharFormat singleLineCommentFormat;
    QTextCharFormat multiLineCommentFormat;
    QTextCharFormat stringFormat;

    SyntaxTheme *m_theme;
};

#endif // CPPSYNTAXHIGHLIGHTER_H
