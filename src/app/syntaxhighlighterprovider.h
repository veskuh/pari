#ifndef SYNTAXHIGHLIGHTERPROVIDER_H
#define SYNTAXHIGHLIGHTERPROVIDER_H

#include <QObject>
#include <QQuickTextDocument>
class QSyntaxHighlighter;

class SyntaxHighlighterProvider : public QObject
{
    Q_OBJECT
public:
    explicit SyntaxHighlighterProvider(QObject *parent = nullptr);

    Q_INVOKABLE void attachHighlighter(QQuickTextDocument *doc, const QString &filePath);

private:
    QSyntaxHighlighter *m_highlighter;
};

#endif // SYNTAXHIGHLIGHTERPROVIDER_H
