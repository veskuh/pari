#ifndef SWIFTSYNTAXHIGHLIGHTER_H
#define SWIFTSYNTAXHIGHLIGHTER_H

#include <QSyntaxHighlighter>
#include <QRegularExpression>
#include <QTextCharFormat>
#include <QVector>
#include "syntaxtheme.h"

class SwiftSyntaxHighlighter : public QSyntaxHighlighter
{
    Q_OBJECT

public:
    explicit SwiftSyntaxHighlighter(QTextDocument *parent = nullptr, SyntaxTheme *theme = nullptr);

    static QStringList supportedExtensions() { return {"swift"}; }
    static QStringList supportedFileNames() { return {}; }

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
    QTextCharFormat typeFormat;
    QTextCharFormat attributeFormat;
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

#endif // SWIFTSYNTAXHIGHLIGHTER_H
