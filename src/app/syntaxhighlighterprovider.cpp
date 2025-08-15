#include "syntaxhighlighterprovider.h"
#include "cppsyntaxhighlighter.h"
#include "qmlsyntaxhighlighter.h"
#include <QFileInfo>

SyntaxHighlighterProvider::SyntaxHighlighterProvider(QObject *parent)
    : QObject{parent}, m_highlighter(nullptr)
{
}

void SyntaxHighlighterProvider::attachHighlighter(QQuickTextDocument *doc, const QString &filePath)
{
    if (!doc)
        return;

    QTextDocument *textDoc = doc->textDocument();
    if (!textDoc)
        return;

    // Clean up any existing highlighter
    if (m_highlighter) {
        m_highlighter->setDocument(nullptr);
        delete m_highlighter;
        m_highlighter = nullptr;
    }

    QFileInfo fileInfo(filePath);
    QString extension = fileInfo.suffix();
    QStringList cppExtensions = {"cpp", "h", "cxx", "hxx", "cc", "hh"};

    if (cppExtensions.contains(extension)) {
        m_highlighter = new CppSyntaxHighlighter(textDoc);
    } else if (extension == "qml") {
        m_highlighter = new QmlSyntaxHighlighter(textDoc);
    }
}
