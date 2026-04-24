#ifndef MARKDOWNFORMATTER_H
#define MARKDOWNFORMATTER_H

#include <QObject>
#include <QString>

class MarkdownFormatter : public QObject
{
    Q_OBJECT
public:
    explicit MarkdownFormatter(QObject *parent = nullptr);
    Q_INVOKABLE QString toHtml(const QString &markdown) const;

private:
    QString escapeHtml(const QString &text) const;
    QString processInlineMarkdown(QString text) const;
};

#endif // MARKDOWNFORMATTER_H
