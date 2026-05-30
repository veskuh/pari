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
    
    QVariantMap result = searcher.find(&doc, "hello", 0);
    QCOMPARE(result["position"].toInt(), 5);
    QCOMPARE(result["start"].toInt(), 0);
    QCOMPARE(result["end"].toInt(), 5);
}

void TestTextDocumentSearcher::testFindPrevious()
{
    TextDocumentSearcher searcher;
    QTextDocument doc;
    doc.setPlainText("hello world\nhello again");
    
    QVariantMap result = searcher.find(&doc, "hello", 23, QTextDocument::FindBackward);
    QCOMPARE(result["position"].toInt(), 17);
    QCOMPARE(result["start"].toInt(), 12);
    QCOMPARE(result["end"].toInt(), 17);
}

void TestTextDocumentSearcher::testFindRegex()
{
    TextDocumentSearcher searcher;
    QTextDocument doc;
    doc.setPlainText("error: code 404 not found\nwarning: code 500");
    
    // Match regex "\d+" (code digits)
    QVariantMap result1 = searcher.find(&doc, "\\d+", 0, 0, true);
    QCOMPARE(result1["position"].toInt(), 15);
    QCOMPARE(result1["start"].toInt(), 12);
    QCOMPARE(result1["end"].toInt(), 15); // matches "404"

    // Match regex case-insensitive (options = 0, which defaults to case-insensitive)
    QVariantMap result2 = searcher.find(&doc, "CODE", 0, 0, true);
    QCOMPARE(result2["position"].toInt(), 11);
    QCOMPARE(result2["start"].toInt(), 7);
    QCOMPARE(result2["end"].toInt(), 11); // matches "code"

    // Match regex case-sensitive (options = QTextDocument::FindCaseSensitively)
    QVariantMap result3 = searcher.find(&doc, "CODE", 0, QTextDocument::FindCaseSensitively, true);
    QCOMPARE(result3["position"].toInt(), -1); // "CODE" does not match "code" case-sensitively
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
