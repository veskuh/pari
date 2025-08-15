#ifndef QMLSYNTAXHIGHLIGHTER_H
#define QMLSYNTAXHIGHLIGHTER_H

#include <QSyntaxHighlighter>
#include <QRegularExpression>
#include <QTextCharFormat>
#include <QVector>

class QmlSyntaxHighlighter : public QSyntaxHighlighter
{
    Q_OBJECT

public:
    explicit QmlSyntaxHighlighter(QTextDocument *parent = nullptr);

protected:
    void highlightBlock(const QString &text) override;

private:
    enum BlockState {
        Normal = 0,
        InComment = 1
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
    QTextCharFormat componentFormat;
    QTextCharFormat propertyFormat;
    QTextCharFormat singleLineCommentFormat;
    QTextCharFormat multiLineCommentFormat;
    QTextCharFormat stringFormat;
};

#endif // QMLSYNTAXHIGHLIGHTER_H
