#include "syntaxhighlighterprovider.h"
#include "cppsyntaxhighlighter.h"
#include "qmlsyntaxhighlighter.h"
#include "shellsyntaxhighlighter.h"
#include "markdownsyntaxhighlighter.h"
#include <QFileInfo>

SyntaxHighlighterProvider::SyntaxHighlighterProvider(QObject *parent)
    : QObject{parent}, m_settings(nullptr)
{
}

void SyntaxHighlighterProvider::setSettings(Settings *settings)
{
    m_settings = settings;
    if (m_settings) {
        connect(m_settings, &Settings::systemThemeIsDarkChanged, this, &SyntaxHighlighterProvider::updateHighlighterTheme);
        connect(m_settings, &Settings::lightThemeChanged, this, &SyntaxHighlighterProvider::updateHighlighterTheme);
        connect(m_settings, &Settings::darkThemeChanged, this, &SyntaxHighlighterProvider::updateHighlighterTheme);
    }
}

void SyntaxHighlighterProvider::attachHighlighter(QQuickTextDocument *doc, const QString &filePath)
{
    if (!doc)
        return;

    QFileInfo fileInfo(filePath);
    QString extension = fileInfo.suffix();
    QStringList cppExtensions = {"cpp", "h", "cxx", "hxx", "cc", "hh"};

    SyntaxTheme *currentTheme = m_settings->systemThemeIsDark() ? m_settings->darkTheme() : m_settings->lightTheme();

    QStringList shellExtensions = {"sh", "bash", "zsh","pro","cmake","py","pl","ps1","rb","conf","ini","cfg","yaml","mk"};
    QStringList buildFiles = {"Makefile", "CMakeLists.txt"};

    QSyntaxHighlighter* higlighter;

    if (cppExtensions.contains(extension)) {
        higlighter = new CppSyntaxHighlighter(doc->textDocument(), currentTheme);
    } else if (extension == "qml") {
        higlighter = new QmlSyntaxHighlighter(doc->textDocument(), currentTheme);
    } else if (shellExtensions.contains(extension) || buildFiles.contains(fileInfo.fileName())) {
        higlighter = new ShellSyntaxHighlighter(doc->textDocument(), currentTheme);
    } else if (extension == "md" || extension == "markdown") {
        higlighter = new MarkdownSyntaxHighlighter(doc->textDocument(), currentTheme);
    }
}

void SyntaxHighlighterProvider::updateHighlighterTheme()
{
    // TODO
}
