#include "test_markdownformatter.h"
#include <QtTest>

void TestMarkdownFormatter::testBold()
{
    QCOMPARE(formatter.toHtml("**bold text**"), QString("<p><b>bold text</b></p>\n"));
}

void TestMarkdownFormatter::testItalics()
{
    QCOMPARE(formatter.toHtml("*italic text*"), QString("<p><i>italic text</i></p>\n"));
}

void TestMarkdownFormatter::testStrikethrough()
{
    QCOMPARE(formatter.toHtml("~~strikethrough text~~"), QString("<p><s>strikethrough text</s></p>\n"));
}

void TestMarkdownFormatter::testLinks()
{
    QCOMPARE(formatter.toHtml("[link text](http://example.com)"), QString("<p><a href=\"http://example.com\">link text</a></p>\n"));
}

void TestMarkdownFormatter::testUnorderedLists()
{
    QString markdown = "* item 1\n* item 2";
    QString expected = "<ul>\n<li>item 1</li>\n<li>item 2</li>\n</ul>\n";
    QCOMPARE(formatter.toHtml(markdown), expected);
}

void TestMarkdownFormatter::testOrderedLists()
{
    QString markdown = "1. item 1\n2. item 2";
    QString expected = "<ol>\n<li>item 1</li>\n<li>item 2</li>\n</ol>\n";
    QCOMPARE(formatter.toHtml(markdown), expected);
}

void TestMarkdownFormatter::testBlockQuotes()
{
    QString markdown = "> quote text";
    QString expected = "<blockquote>quote text<br></blockquote>\n";
    QCOMPARE(formatter.toHtml(markdown), expected);
}

void TestMarkdownFormatter::testCodeBlocks()
{
    QString markdown = "```\ncode block\n```";
    QString expected = "<pre><code>code block\n</code></pre>\n";
    QCOMPARE(formatter.toHtml(markdown), expected);
}

void TestMarkdownFormatter::testMixedContent()
{
    QString markdown = "This is **bold** and *italic*.";
    QString expected = "<p>This is <b>bold</b> and <i>italic</i>.</p>\n";
    QCOMPARE(formatter.toHtml(markdown), expected);
}

void TestMarkdownFormatter::testEscapeHtml()
{
    QString markdown = "<script>alert('xss')</script>";
    QString expected = "<p>&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;</p>\n";
    QCOMPARE(formatter.toHtml(markdown), expected);
}
