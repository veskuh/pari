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

    struct HighlightRange {
        int start;
        int length;
        QTextCharFormat format;
    };
    QList<HighlightRange> highlightLine(const QString &text);

protected:
    void highlightBlock(const QString &text) override;

private:
    enum BlockState {
        Normal = 0,
        InComment = 1,
    };

    struct HighlightingRule
    {
        QRegularExpression pattern;
        QTextCharFormat format;
    };
    QVector<HighlightingRule> highlightingRules;

    QTextCharFormat keywordFormat;
    QTextCharFormat includeFormat;
    QTextCharFormat macroFormat;
    QTextCharFormat singleLineCommentFormat;
    QTextCharFormat multiLineCommentFormat;
    QTextCharFormat stringFormat;

    QRegularExpression stringExpression;
    QRegularExpression singleLineCommentExpression;
    QRegularExpression mlcStart;
    QRegularExpression mlcEnd;
    QRegularExpression commentStart;
    QRegularExpression commentEnd;

    SyntaxTheme *m_theme;
};

#endif // CPPSYNTAXHIGHLIGHTER_H
