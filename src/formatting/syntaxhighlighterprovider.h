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

    static QStringList supportedExtensions();
    static QStringList supportedFileNames();
    Q_INVOKABLE void attachHighlighter(QQuickTextDocument *doc, const QString &filePath);
    void setSettings(Settings *settings);

private slots:
    void updateHighlighterTheme();

private:
    Settings *m_settings;
};

#endif // SYNTAXHIGHLIGHTERPROVIDER_H
