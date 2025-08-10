#ifndef MARKDOWNFORMATTER_H
#define MARKDOWNFORMATTER_H

#include <QString>

class MarkdownFormatter
{
public:
    MarkdownFormatter();
    QString toHtml(const QString &markdown);

private:
    QString escapeHtml(const QString &text);
};

#endif // MARKDOWNFORMATTER_H
