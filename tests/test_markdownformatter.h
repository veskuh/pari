#ifndef TEST_MARKDOWNFORMATTER_H
#define TEST_MARKDOWNFORMATTER_H

#include <QObject>

class TestMarkdownFormatter : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void testStrikethrough();
    void testLinks();
    void testUnorderedLists();
    void testOrderedLists();
    void testBlockQuotes();
    void testCodeBlocks();
    void testMixedContent();
    void testEscapeHtml();
    void testUnorderedListsWithDash();
};

#endif // TEST_MARKDOWNFORMATTER_H
