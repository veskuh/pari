#include "test_markdownformatter.h"
#include "markdownformatter.h"
#include <QtTest>

void TestMarkdownFormatter::initTestCase()
{
}

void TestMarkdownFormatter::cleanupTestCase()
{
}

void TestMarkdownFormatter::testStrikethrough()
{
    MarkdownFormatter formatter;
    QVERIFY(formatter.toHtml("~~strike~~").contains("<s>strike</s>"));
}

void TestMarkdownFormatter::testLinks()
{
    MarkdownFormatter formatter;
    QVERIFY(formatter.toHtml("[link](http://example.com)").contains("<a href=\"http://example.com\">link</a>"));
}

void TestMarkdownFormatter::testUnorderedLists()
{
    MarkdownFormatter formatter;
    QString markdown = "* item 1\n* item 2";
    QString html = formatter.toHtml(markdown);
    QVERIFY(html.contains("<ul>"));
    QVERIFY(html.contains("<li>item 1</li>"));
    QVERIFY(html.contains("<li>item 2</li>"));
}

void TestMarkdownFormatter::testOrderedLists()
{
    MarkdownFormatter formatter;
    QString markdown = "1. item 1\n2. item 2";
    QString html = formatter.toHtml(markdown);
    QVERIFY(html.contains("<ol>"));
    QVERIFY(html.contains("<li>item 1</li>"));
    QVERIFY(html.contains("<li>item 2</li>"));
}

void TestMarkdownFormatter::testBlockQuotes()
{
    MarkdownFormatter formatter;
    QString html = formatter.toHtml("> quote");
    QVERIFY(html.contains("<blockquote>quote"));
}

void TestMarkdownFormatter::testCodeBlocks()
{
    MarkdownFormatter formatter;
    QString markdown = "```cpp\nint x = 0;\n```";
    QString html = formatter.toHtml(markdown);
    QVERIFY(html.contains("<pre><code>int x = 0;"));
}

void TestMarkdownFormatter::testMixedContent()
{
    MarkdownFormatter formatter;
    QString markdown = "**bold** and *italic*";
    QString html = formatter.toHtml(markdown);
    QVERIFY(html.contains("bold"));
    QVERIFY(html.contains("italic"));
}

void TestMarkdownFormatter::testEscapeHtml()
{
    MarkdownFormatter formatter;
    QVERIFY(formatter.toHtml("<script>").contains("&lt;script&gt;"));
}

void TestMarkdownFormatter::testUnorderedListsWithDash()
{
    MarkdownFormatter formatter;
    QString markdown = "- item 1\n- item 2";
    QString html = formatter.toHtml(markdown);
    QVERIFY(html.contains("<ul>"));
    QVERIFY(html.contains("<li>item 1</li>"));
    QVERIFY(html.contains("<li>item 2</li>"));
}
