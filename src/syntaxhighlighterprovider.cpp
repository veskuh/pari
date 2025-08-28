#include "syntaxhighlighterprovider.h"
#include "cppsyntaxhighlighter.h"
#include "qmlsyntaxhighlighter.h"
#include "shellsyntaxhighlighter.h"
#include "markdownsyntaxhighlighter.h"
#include <QFileInfo>

SyntaxHighlighterProvider::SyntaxHighlighterProvider(QObject *parent)
    : QObject{parent}, m_highlighter(nullptr), m_settings(nullptr), m_document(nullptr)
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

    m_document = doc;
    m_filePath = filePath;

    updateHighlighterTheme();
}

void SyntaxHighlighterProvider::updateHighlighterTheme()
{
    if (!m_document || m_filePath.isEmpty() || !m_settings)
        return;

    QTextDocument *textDoc = m_document->textDocument();
    if (!textDoc)
        return;

    // Clean up any existing highlighter
    if (m_highlighter) {
        m_highlighter->setDocument(nullptr);
        delete m_highlighter;
        m_highlighter = nullptr;
    }

    QFileInfo fileInfo(m_filePath);
    QString extension = fileInfo.suffix();
    QStringList cppExtensions = {"cpp", "h", "cxx", "hxx", "cc", "hh"};

    SyntaxTheme *currentTheme = m_settings->systemThemeIsDark() ? m_settings->darkTheme() : m_settings->lightTheme();

    QStringList shellExtensions = {"sh", "bash", "zsh","pro","cmake","py","pl","ps1","rb","conf","ini","cfg","yaml","mk"};
    QStringList buildFiles = {"Makefile", "CMakeLists.txt"};

    if (cppExtensions.contains(extension)) {
        m_highlighter = new CppSyntaxHighlighter(textDoc, currentTheme);
    } else if (extension == "qml") {
        m_highlighter = new QmlSyntaxHighlighter(textDoc, currentTheme);
    } else if (shellExtensions.contains(extension) || buildFiles.contains(fileInfo.fileName())) {
        m_highlighter = new ShellSyntaxHighlighter(textDoc, currentTheme);
    } else if (extension == "md" || extension == "markdown") {
        m_highlighter = new MarkdownSyntaxHighlighter(textDoc, currentTheme);
    }
}
