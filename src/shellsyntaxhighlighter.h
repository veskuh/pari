#ifndef SHELLSYNTAXHIGHLIGHTER_H
#define SHELLSYNTAXHIGHLIGHTER_H

#include <QSyntaxHighlighter>
#include <QRegularExpression>
#include <QTextCharFormat>
#include "settings.h"

class ShellSyntaxHighlighter : public QSyntaxHighlighter
{
    Q_OBJECT

public:
    explicit ShellSyntaxHighlighter(QTextDocument *parent = nullptr, SyntaxTheme *theme = nullptr);

protected:
    void highlightBlock(const QString &text) override;

private:
    QTextCharFormat commentFormat;
    QTextCharFormat stringFormat;

    SyntaxTheme *m_theme;
};

#endif // SHELLSYNTAXHIGHLIGHTER_H
