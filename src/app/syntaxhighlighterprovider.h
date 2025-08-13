#ifndef SYNTAXHIGHLIGHTERPROVIDER_H
#define SYNTAXHIGHLIGHTERPROVIDER_H

#include <QObject>
#include <QQuickTextDocument>
#include "cppsyntaxhighlighter.h"

class SyntaxHighlighterProvider : public QObject
{
    Q_OBJECT
public:
    explicit SyntaxHighlighterProvider(QObject *parent = nullptr);

    Q_INVOKABLE void attachHighlighter(QQuickTextDocument *doc, const QString &filePath);

private:
    CppSyntaxHighlighter *m_highlighter;
};

#endif // SYNTAXHIGHLIGHTERPROVIDER_H
