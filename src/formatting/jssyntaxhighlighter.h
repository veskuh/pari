#ifndef JSSYNTAXHIGHLIGHTER_H
#define JSSYNTAXHIGHLIGHTER_H

#include <QSyntaxHighlighter>
#include <QRegularExpression>
#include <QTextCharFormat>
#include <QVector>
#include "syntaxtheme.h"

class JsSyntaxHighlighter : public QSyntaxHighlighter
{
    Q_OBJECT

public:
    explicit JsSyntaxHighlighter(QTextDocument *parent = nullptr, SyntaxTheme *theme = nullptr);

    static QStringList supportedExtensions() { return {"js"}; }
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
    QTextCharFormat functionFormat;
    QTextCharFormat singleLineCommentFormat;
    QTextCharFormat multiLineCommentFormat;
    QTextCharFormat stringFormat;
    QTextCharFormat numberFormat;

    QRegularExpression stringExpression;
    QRegularExpression singleLineCommentExpression;
    QRegularExpression mlcStart;
    QRegularExpression mlcEnd;
    QRegularExpression commentStart;
    QRegularExpression commentEnd;

    SyntaxTheme *m_theme;
};

#endif // JSSYNTAXHIGHLIGHTER_H
