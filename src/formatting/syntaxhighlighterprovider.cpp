#include "syntaxhighlighterprovider.h"
#include "cppsyntaxhighlighter.h"
#include "swiftsyntaxhighlighter.h"
#include "jssyntaxhighlighter.h"
#include "javasyntaxhighlighter.h"
#include "kotlinsyntaxhighlighter.h"
#include "rustsyntaxhighlighter.h"
#include "gosyntaxhighlighter.h"
#include "qmlsyntaxhighlighter.h"
#include "shellsyntaxhighlighter.h"
#include "markdownsyntaxhighlighter.h"
#include <QFileInfo>
#include <functional>

struct HighlighterRegistryEntry {
    QStringList extensions;
    QStringList fileNames;
    std::function<QSyntaxHighlighter*(QTextDocument*, SyntaxTheme*)> factory;
};

static QList<HighlighterRegistryEntry> highlighterRegistry() {
    static QList<HighlighterRegistryEntry> registry = {
        { CppSyntaxHighlighter::supportedExtensions(), CppSyntaxHighlighter::supportedFileNames(), 
          [](QTextDocument* doc, SyntaxTheme* theme) { return new CppSyntaxHighlighter(doc, theme); } },
        { SwiftSyntaxHighlighter::supportedExtensions(), SwiftSyntaxHighlighter::supportedFileNames(), 
          [](QTextDocument* doc, SyntaxTheme* theme) { return new SwiftSyntaxHighlighter(doc, theme); } },
        { JsSyntaxHighlighter::supportedExtensions(), JsSyntaxHighlighter::supportedFileNames(), 
          [](QTextDocument* doc, SyntaxTheme* theme) { return new JsSyntaxHighlighter(doc, theme); } },
        { JavaSyntaxHighlighter::supportedExtensions(), JavaSyntaxHighlighter::supportedFileNames(), 
          [](QTextDocument* doc, SyntaxTheme* theme) { return new JavaSyntaxHighlighter(doc, theme); } },
        { KotlinSyntaxHighlighter::supportedExtensions(), KotlinSyntaxHighlighter::supportedFileNames(), 
          [](QTextDocument* doc, SyntaxTheme* theme) { return new KotlinSyntaxHighlighter(doc, theme); } },
        { RustSyntaxHighlighter::supportedExtensions(), RustSyntaxHighlighter::supportedFileNames(), 
          [](QTextDocument* doc, SyntaxTheme* theme) { return new RustSyntaxHighlighter(doc, theme); } },
        { GoSyntaxHighlighter::supportedExtensions(), GoSyntaxHighlighter::supportedFileNames(), 
          [](QTextDocument* doc, SyntaxTheme* theme) { return new GoSyntaxHighlighter(doc, theme); } },
        { QmlSyntaxHighlighter::supportedExtensions(), QmlSyntaxHighlighter::supportedFileNames(), 
          [](QTextDocument* doc, SyntaxTheme* theme) { return new QmlSyntaxHighlighter(doc, theme); } },
        { ShellSyntaxHighlighter::supportedExtensions(), ShellSyntaxHighlighter::supportedFileNames(), 
          [](QTextDocument* doc, SyntaxTheme* theme) { return new ShellSyntaxHighlighter(doc, theme); } },
        { MarkdownSyntaxHighlighter::supportedExtensions(), MarkdownSyntaxHighlighter::supportedFileNames(), 
          [](QTextDocument* doc, SyntaxTheme* theme) { return new MarkdownSyntaxHighlighter(doc, theme); } }
    };
    return registry;
}

SyntaxHighlighterProvider::SyntaxHighlighterProvider(QObject *parent)
    : QObject{parent}, m_settings(nullptr)
{
}

QStringList SyntaxHighlighterProvider::supportedExtensions()
{
    QStringList exts;
    for (const auto &entry : highlighterRegistry()) {
        exts << entry.extensions;
    }
    // Also add plain text if not already there
    if (!exts.contains("txt")) exts << "txt";
    return exts;
}

QStringList SyntaxHighlighterProvider::supportedFileNames()
{
    QStringList names;
    for (const auto &entry : highlighterRegistry()) {
        names << entry.fileNames;
    }
    return names;
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
    QString extension = fileInfo.suffix().toLower();
    QString fileName = fileInfo.fileName();
    
    SyntaxTheme *currentTheme = m_settings->systemThemeIsDark() ? m_settings->darkTheme() : m_settings->lightTheme();

    for (const auto &entry : highlighterRegistry()) {
        if (entry.extensions.contains(extension) || entry.fileNames.contains(fileName)) {
            entry.factory(doc->textDocument(), currentTheme);
            return;
        }
    }
}

void SyntaxHighlighterProvider::updateHighlighterTheme()
{
    // TODO
}
