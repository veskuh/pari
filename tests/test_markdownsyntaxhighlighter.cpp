#include "test_markdownsyntaxhighlighter.h"
#include "../src/app/markdownsyntaxhighlighter.h"
#include "../src/app/syntaxtheme.h"
#include <QTextDocument>
#include <QTest>

void TestMarkdownSyntaxHighlighter::initTestCase()
{
    // Initialization for all tests
}

void TestMarkdownSyntaxHighlighter::cleanupTestCase()
{
    // Cleanup after all tests
}

void TestMarkdownSyntaxHighlighter::testHighlight_Headers()
{
    QTextDocument doc;
    SyntaxTheme theme;
    theme.keywordColor = QColor("red");
    MarkdownSyntaxHighlighter highlighter(&doc, &theme);

    doc.setPlainText("# This is a header");
    highlighter.rehighlight();

    QTextBlock block = doc.firstBlock();
    QTextLayout *layout = block.layout();
    QList<QTextLayout::FormatRange> formats = layout->formats();

    QVERIFY(!formats.isEmpty());
    QCOMPARE(formats.first().format.foreground().color(), QColor("red"));
    QCOMPARE(formats.first().format.fontWeight(), QFont::Bold);
}

void TestMarkdownSyntaxHighlighter::testHighlight_Bold()
{
    QTextDocument doc;
    SyntaxTheme theme;
    MarkdownSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("**bold text**");
    highlighter.rehighlight();
    QTextBlock block = doc.firstBlock();
    QTextLayout *layout = block.layout();
    QList<QTextLayout::FormatRange> formats = layout->formats();
    QVERIFY(!formats.isEmpty());
    QCOMPARE(formats.first().format.fontWeight(), QFont::Bold);
}

void TestMarkdownSyntaxHighlighter::testHighlight_Italic()
{
    QTextDocument doc;
    SyntaxTheme theme;
    MarkdownSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("*italic text*");
    highlighter.rehighlight();
    QTextBlock block = doc.firstBlock();
    QTextLayout *layout = block.layout();
    QList<QTextLayout::FormatRange> formats = layout->formats();
    QVERIFY(!formats.isEmpty());
    QCOMPARE(formats.first().format.fontItalic(), true);
}

void TestMarkdownSyntaxHighlighter::testHighlight_Links()
{
    QTextDocument doc;
    SyntaxTheme theme;
    theme.stringColor = QColor("blue");
    MarkdownSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("[link](http://example.com)");
    highlighter.rehighlight();
    QTextBlock block = doc.firstBlock();
    QTextLayout *layout = block.layout();
    QList<QTextLayout::FormatRange> formats = layout->formats();
    QVERIFY(!formats.isEmpty());
    QCOMPARE(formats.first().format.foreground().color(), QColor("blue"));
    QCOMPARE(formats.first().format.fontUnderline(), true);
}

void TestMarkdownSyntaxHighlighter::testHighlight_Images()
{
    QTextDocument doc;
    SyntaxTheme theme;
    theme.stringColor = QColor("green");
    MarkdownSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("![alt](image.png)");
    highlighter.rehighlight();
    QTextBlock block = doc.firstBlock();
    QTextLayout *layout = block.layout();
    QList<QTextLayout::FormatRange> formats = layout->formats();
    QVERIFY(!formats.isEmpty());
    QCOMPARE(formats.first().format.foreground().color(), QColor("green"));
}

void TestMarkdownSyntaxHighlighter::testHighlight_Blockquotes()
{
    QTextDocument doc;
    SyntaxTheme theme;
    theme.commentColor = QColor("gray");
    MarkdownSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("> blockquote");
    highlighter.rehighlight();
    QTextBlock block = doc.firstBlock();
    QTextLayout *layout = block.layout();
    QList<QTextLayout::FormatRange> formats = layout->formats();
    QVERIFY(!formats.isEmpty());
    QCOMPARE(formats.first().format.foreground().color(), QColor("gray"));
    QCOMPARE(formats.first().format.fontItalic(), true);
}

void TestMarkdownSyntaxHighlighter::testHighlight_InlineCode()
{
    QTextDocument doc;
    SyntaxTheme theme;
    theme.stringColor = QColor("purple");
    MarkdownSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("`code`");
    highlighter.rehighlight();
    QTextBlock block = doc.firstBlock();
    QTextLayout *layout = block.layout();
    QList<QTextLayout::FormatRange> formats = layout->formats();
    QVERIFY(!formats.isEmpty());
    QCOMPARE(formats.first().format.foreground().color(), QColor("purple"));
}

void TestMarkdownSyntaxHighlighter::testHighlight_CodeBlocks()
{
    QTextDocument doc;
    SyntaxTheme theme;
    theme.stringColor = QColor("orange");
    MarkdownSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("```\ncode block\n```");
    highlighter.rehighlight();

    // Check the line with "code block"
    QTextBlock block = doc.firstBlock().next();
    QTextLayout *layout = block.layout();
    QList<QTextLayout::FormatRange> formats = layout->formats();

    // It should have the code block format applied to the whole block.
    // The highlightBlock function applies the format to the whole line inside a block.
    // So we check the format of the first character.
    QVERIFY(!formats.isEmpty());
    QCOMPARE(formats.first().format.foreground().color(), QColor("orange"));
}

void TestMarkdownSyntaxHighlighter::testHighlight_Comments()
{
    QTextDocument doc;
    SyntaxTheme theme;
    theme.commentColor = QColor("silver");
    MarkdownSyntaxHighlighter highlighter(&doc, &theme);
    doc.setPlainText("<!-- comment -->");
    highlighter.rehighlight();
    QTextBlock block = doc.firstBlock();
    QTextLayout *layout = block.layout();
    QList<QTextLayout::FormatRange> formats = layout->formats();
    QVERIFY(!formats.isEmpty());
    QCOMPARE(formats.first().format.foreground().color(), QColor("silver"));
}
