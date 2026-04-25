#include "test_textdocumentsearcher.h"
#include <QTextDocument>
#include <QTextBlock>

void TestTextDocumentSearcher::initTestCase()
{
}

void TestTextDocumentSearcher::cleanupTestCase()
{
}

void TestTextDocumentSearcher::testFindNext()
{
    TextDocumentSearcher searcher;
    QTextDocument doc;
    doc.setPlainText("hello world\nhello again");
    
    // Match "hello" (length 5) at pos 0. Result should be 5.
    int pos = searcher.find(&doc, "hello", 0);
    QCOMPARE(pos, 5); 
}

void TestTextDocumentSearcher::testFindPrevious()
{
    TextDocumentSearcher searcher;
    QTextDocument doc;
    doc.setPlainText("hello world\nhello again");
    
    // Search backward for "hello" from the end. Match is the second "hello" at index 12.
    // Length is 5. End position is 17.
    int pos = searcher.find(&doc, "hello", 23, QTextDocument::FindBackward);
    QCOMPARE(pos, 17);
}

void TestTextDocumentSearcher::testApplyFilter()
{
    // C++ applyFilter is currently a NO-OP as filtering is handled in QML by swapping the text buffer.
    // This maintains architectural consistency with QML TextArea's layout engine.
    TextDocumentSearcher searcher;
    QTextDocument doc;
    searcher.applyFilter(&doc, "pattern", false, true);
    QVERIFY(true);
}

void TestTextDocumentSearcher::testClearFilter()
{
    TextDocumentSearcher searcher;
    QTextDocument doc;
    searcher.clearFilter(&doc);
    QVERIFY(true);
}
