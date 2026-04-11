#include "test_textdocumentsearcher.h"
#include "textdocumentsearcher.h"
#include "mocktextdocument.h"
#include <QTextDocument>

void TestTextDocumentSearcher::initTestCase()
{
}

void TestTextDocumentSearcher::cleanupTestCase()
{
}

void TestTextDocumentSearcher::testFindNext()
{
    QTextDocument doc;
    doc.setPlainText("hello world\nhello again");
    MockTextDocument mockDoc(&doc);
    
    TextDocumentSearcher searcher;
    
    // First occurrence
    int pos1 = searcher.find(&mockDoc, "hello", 0);
    QCOMPARE(pos1, 5); 
    
    // Second occurrence
    int pos2 = searcher.find(&mockDoc, "hello", 5);
    QCOMPARE(pos2, 17);
}

void TestTextDocumentSearcher::testFindPrevious()
{
    QTextDocument doc;
    doc.setPlainText("hello world\nhello again");
    MockTextDocument mockDoc(&doc);
    
    TextDocumentSearcher searcher;
    
    // Previous from end (options = 1 is QTextDocument::FindBackward)
    int pos1 = searcher.find(&mockDoc, "hello", 20, 1);
    QCOMPARE(pos1, 17);
    
    // Previous from middle
    int pos2 = searcher.find(&mockDoc, "hello", 10, 1);
    QCOMPARE(pos2, 5);
}
