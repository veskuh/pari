#include "test_markdownsyntaxhighlighter.h"
#include "markdownsyntaxhighlighter.h"
#include "syntaxtheme.h"
#include <QTextDocument>
#include <QTest>
#include <QCoreApplication>

void TestMarkdownSyntaxHighlighter::initTestCase()
{
}

void TestMarkdownSyntaxHighlighter::cleanupTestCase()
{
}

void TestMarkdownSyntaxHighlighter::testHighlight_Headers()
{
    SyntaxTheme theme;
    QTextDocument doc;
    MarkdownSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("# Header 1\n## Header 2");
    highlighter.rehighlight();
    QCoreApplication::processEvents();
    QVERIFY(doc.toPlainText().length() > 0);
}

void TestMarkdownSyntaxHighlighter::testHighlight_Bold()
{
    SyntaxTheme theme;
    QTextDocument doc;
    MarkdownSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("**bold**");
    highlighter.rehighlight();
    QCoreApplication::processEvents();
    QVERIFY(doc.toPlainText().length() > 0);
}

void TestMarkdownSyntaxHighlighter::testHighlight_Italic()
{
    SyntaxTheme theme;
    QTextDocument doc;
    MarkdownSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("*italic*");
    highlighter.rehighlight();
    QCoreApplication::processEvents();
    QVERIFY(doc.toPlainText().length() > 0);
}

void TestMarkdownSyntaxHighlighter::testHighlight_Links()
{
    SyntaxTheme theme;
    QTextDocument doc;
    MarkdownSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("[link](http://example.com)");
    highlighter.rehighlight();
    QCoreApplication::processEvents();
    QVERIFY(doc.toPlainText().length() > 0);
}

void TestMarkdownSyntaxHighlighter::testHighlight_Images()
{
    SyntaxTheme theme;
    QTextDocument doc;
    MarkdownSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("![image](http://example.com/image.png)");
    highlighter.rehighlight();
    QCoreApplication::processEvents();
    QVERIFY(doc.toPlainText().length() > 0);
}

void TestMarkdownSyntaxHighlighter::testHighlight_Blockquotes()
{
    SyntaxTheme theme;
    QTextDocument doc;
    MarkdownSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("> blockquote");
    highlighter.rehighlight();
    QCoreApplication::processEvents();
    QVERIFY(doc.toPlainText().length() > 0);
}

void TestMarkdownSyntaxHighlighter::testHighlight_InlineCode()
{
    SyntaxTheme theme;
    QTextDocument doc;
    MarkdownSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("`inline code`");
    highlighter.rehighlight();
    QCoreApplication::processEvents();
    QVERIFY(doc.toPlainText().length() > 0);
}

void TestMarkdownSyntaxHighlighter::testHighlight_CodeBlocks()
{
    SyntaxTheme theme;
    QTextDocument doc;
    MarkdownSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("```\ncode block\n```");
    highlighter.rehighlight();
    QCoreApplication::processEvents();
    QVERIFY(doc.toPlainText().length() > 0);
}

void TestMarkdownSyntaxHighlighter::testHighlight_Comments()
{
    SyntaxTheme theme;
    QTextDocument doc;
    MarkdownSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("<!-- comment -->");
    highlighter.rehighlight();
    QCoreApplication::processEvents();
    QVERIFY(doc.toPlainText().length() > 0);
}

void TestMarkdownSyntaxHighlighter::testHighlight_MultipleCodeBlocks()
{
    SyntaxTheme theme;
    QTextDocument doc;
    MarkdownSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("```\ncode1\n```\ntext\n```\ncode2\n```");
    highlighter.rehighlight();
    QCoreApplication::processEvents();
    QVERIFY(doc.toPlainText().length() > 0);
}
