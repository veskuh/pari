#ifndef TEST_MARKDOWNFORMATTER_H
#define TEST_MARKDOWNFORMATTER_H

#include <QObject>
#include "../src/app/markdownformatter.h"

class TestMarkdownFormatter : public QObject
{
    Q_OBJECT

private:
    MarkdownFormatter formatter;

private slots:
    void testBold();
    void testItalics();
    void testStrikethrough();
    void testLinks();
    void testUnorderedLists();
    void testOrderedLists();
    void testBlockQuotes();
    void testCodeBlocks();
    void testMixedContent();
    void testEscapeHtml();
};

#endif // TEST_MARKDOWNFORMATTER_H
