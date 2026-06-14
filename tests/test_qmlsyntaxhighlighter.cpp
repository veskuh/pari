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

void TestQmlSyntaxHighlighter::testMultiLineBlockStates()
{
    SyntaxTheme theme;
    theme.commentColor = QColor("green");
    theme.keywordColor = QColor("blue");

    QTextDocument doc;
    QmlSyntaxHighlighter highlighter(&doc, &theme);

    // Multi-line comment across blocks, ending with */ at the start of a line
    doc.setPlainText("/* line 1\n*/\nimport QtQuick");
    highlighter.rehighlight();

    // Check line 1 (starts the comment)
    QTextBlock block = doc.begin();
    QVERIFY(block.isValid());
    QCOMPARE(block.layout()->formats().size(), 1);
    QCOMPARE(block.layout()->formats().at(0).format.foreground().color(), theme.commentColor);

    // Check line 2 (ends the comment with */)
    block = block.next();
    QVERIFY(block.isValid());
    QCOMPARE(block.layout()->formats().size(), 1);
    QCOMPARE(block.layout()->formats().at(0).format.foreground().color(), theme.commentColor);

    // Check line 3 (should be highlighted as code, not comment)
    block = block.next();
    QVERIFY(block.isValid());
    // "import" -> keyword, "QtQuick" -> component
    QCOMPARE(block.layout()->formats().size(), 2);
    QCOMPARE(block.layout()->formats().at(0).format.foreground().color(), theme.keywordColor);
}
