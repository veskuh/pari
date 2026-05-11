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

    static QStringList supportedExtensions() { 
        return {"sh", "bash", "zsh", "pro", "cmake", "py", "pl", "ps1", "rb", "conf", "ini", "cfg", "yaml", "mk"}; 
    }
    static QStringList supportedFileNames() { 
        return {"Makefile", "CMakeLists.txt"}; 
    }

protected:
    void highlightBlock(const QString &text) override;

private:
    QTextCharFormat commentFormat;
    QTextCharFormat stringFormat;

    SyntaxTheme *m_theme;
};

#endif // SHELLSYNTAXHIGHLIGHTER_H
