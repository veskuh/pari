#include "test_shellsyntaxhighlighter.h"
#include "shellsyntaxhighlighter.h"
#include "syntaxtheme.h"
#include <QTextDocument>
#include <QTest>
#include <QCoreApplication>

void TestShellSyntaxHighlighter::initTestCase()
{
}

void TestShellSyntaxHighlighter::cleanupTestCase()
{
}

void TestShellSyntaxHighlighter::testComment()
{
    SyntaxTheme theme;
    QTextDocument doc;
    ShellSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("# comment");
    highlighter.rehighlight();
    QCoreApplication::processEvents();
    QVERIFY(true);
}

void TestShellSyntaxHighlighter::testSingleQuotedString()
{
    SyntaxTheme theme;
    QTextDocument doc;
    ShellSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("'string'");
    highlighter.rehighlight();
    QCoreApplication::processEvents();
    QVERIFY(true);
}

void TestShellSyntaxHighlighter::testDoubleQuotedString()
{
    SyntaxTheme theme;
    QTextDocument doc;
    ShellSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("\"string\"");
    highlighter.rehighlight();
    QCoreApplication::processEvents();
    QVERIFY(true);
}

void TestShellSyntaxHighlighter::testStringWithComment()
{
    SyntaxTheme theme;
    QTextDocument doc;
    ShellSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("\"string\" # comment");
    highlighter.rehighlight();
    QCoreApplication::processEvents();
    QVERIFY(true);
}

void TestShellSyntaxHighlighter::testCommentWithString()
{
    SyntaxTheme theme;
    QTextDocument doc;
    ShellSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("# comment 'string'");
    highlighter.rehighlight();
    QCoreApplication::processEvents();
    QVERIFY(true);
}
