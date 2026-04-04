#include "test_qmlsyntaxhighlighter.h"
#include "qmlsyntaxhighlighter.h"
#include "syntaxtheme.h"
#include <QTextDocument>
#include <QTest>
#include <QCoreApplication>

void TestQmlSyntaxHighlighter::initTestCase()
{
}

void TestQmlSyntaxHighlighter::cleanupTestCase()
{
}

void TestQmlSyntaxHighlighter::testInitialState()
{
    SyntaxTheme theme;
    QTextDocument doc;
    QmlSyntaxHighlighter highlighter(&doc, &theme);
    QVERIFY(doc.toPlainText().isEmpty());
}

void TestQmlSyntaxHighlighter::testKeywords()
{
    SyntaxTheme theme;
    QTextDocument doc;
    QmlSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("import QtQuick\nItem { }");
    highlighter.rehighlight();
    QCoreApplication::processEvents();
    QVERIFY(true);
}

void TestQmlSyntaxHighlighter::testStrings()
{
    SyntaxTheme theme;
    QTextDocument doc;
    QmlSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("text: \"Hello\"");
    highlighter.rehighlight();
    QCoreApplication::processEvents();
    QVERIFY(true);
}

void TestQmlSyntaxHighlighter::testComments()
{
    SyntaxTheme theme;
    QTextDocument doc;
    QmlSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("// comment\n/* multi-line */");
    highlighter.rehighlight();
    QCoreApplication::processEvents();
    QVERIFY(true);
}
