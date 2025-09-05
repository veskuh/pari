#ifndef SYNTAXHIGHLIGHTERPROVIDER_H
#define SYNTAXHIGHLIGHTERPROVIDER_H

#include <QObject>
#include <QQuickTextDocument>
#include "settings.h"

class QSyntaxHighlighter;

class SyntaxHighlighterProvider : public QObject
{
    Q_OBJECT
public:
    explicit SyntaxHighlighterProvider(QObject *parent = nullptr);

    Q_INVOKABLE void attachHighlighter(QQuickTextDocument *doc, const QString &filePath);
    void setSettings(Settings *settings);

private slots:
    void updateHighlighterTheme();

private:
    QSyntaxHighlighter *m_highlighter;
    Settings *m_settings;
    QQuickTextDocument *m_document;
    QString m_filePath;
};

#endif // SYNTAXHIGHLIGHTERPROVIDER_H
