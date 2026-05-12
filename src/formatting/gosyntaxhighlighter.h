#ifndef GOSYNTAXHIGHLIGHTER_H
#define GOSYNTAXHIGHLIGHTER_H

#include <QSyntaxHighlighter>
#include <QRegularExpression>
#include <QTextCharFormat>
#include <QVector>
#include "settings.h"

class GoSyntaxHighlighter : public QSyntaxHighlighter
{
    Q_OBJECT

public:
    explicit GoSyntaxHighlighter(QTextDocument *parent = nullptr, SyntaxTheme *theme = nullptr);

    static QStringList supportedExtensions() { return {"go"}; }
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
        InRawString = 2
    };

    struct HighlightingRule
    {
        QRegularExpression pattern;
        QTextCharFormat format;
    };
    QVector<HighlightingRule> highlightingRules;

    QTextCharFormat keywordFormat;
    QTextCharFormat typeFormat;
    QTextCharFormat singleLineCommentFormat;
    QTextCharFormat multiLineCommentFormat;
    QTextCharFormat stringFormat;
    QTextCharFormat constantFormat;

    QRegularExpression stringExpression;
    QRegularExpression rawStringStart;
    QRegularExpression rawStringEnd;
    QRegularExpression singleLineCommentExpression;
    QRegularExpression mlcStart;
    QRegularExpression mlcEnd;

    SyntaxTheme *m_theme;
};

#endif // GOSYNTAXHIGHLIGHTER_H
