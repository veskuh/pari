#include "test_cppsyntaxhighlighter.h"
#include "cppsyntaxhighlighter.h"
#include <QTextDocument>

void TestCppSyntaxHighlighter::initTestCase()
{
}

void TestCppSyntaxHighlighter::cleanupTestCase()
{
}

void TestCppSyntaxHighlighter::testKeywords()
{
    QTextDocument doc;
    CppSyntaxHighlighter highlighter(&doc);
    doc.setPlainText("int main() { return 0; }");
    
    // "int" is a keyword (typically at position 0, length 3)
    QTextBlock block = doc.begin();
    QList<QTextLayout::FormatRange> formats = block.layout()->formats();
    bool foundKeyword = false;
    for (const auto &range : formats) {
        if (range.start == 0 && range.length == 3) {
            foundKeyword = true;
            break;
        }
    }
    QVERIFY(foundKeyword);
}

void TestCppSyntaxHighlighter::testStrings()
{
    QTextDocument doc;
    CppSyntaxHighlighter highlighter(&doc);
    doc.setPlainText("const char* s = \"hello world\";");
    
    QTextBlock block = doc.begin();
    QList<QTextLayout::FormatRange> formats = block.layout()->formats();
    bool foundString = false;
    for (const auto &range : formats) {
        if (range.start >= 16 && range.length == 13) { // "\"hello world\""
            foundString = true;
            break;
        }
    }
    QVERIFY(foundString);
}

void TestCppSyntaxHighlighter::testComments()
{
    QTextDocument doc;
    CppSyntaxHighlighter highlighter(&doc);
    doc.setPlainText("// this is a comment\nint x = 1; /* multiline\ncomment */");
    
    // Single line
    QTextBlock block = doc.begin();
    QList<QTextLayout::FormatRange> formats = block.layout()->formats();
    QVERIFY(!formats.isEmpty());
    
    // Multi line
    block = doc.lastBlock();
    highlighter.rehighlight();
    formats = block.layout()->formats();
    QVERIFY(!formats.isEmpty());
}

void TestCppSyntaxHighlighter::testMultilineComments()
{
    QTextDocument doc;
    CppSyntaxHighlighter highlighter(&doc);
    doc.setPlainText("/* start\n middle\n end */");
    
    QTextBlock block = doc.begin();
    while (block.isValid()) {
        QList<QTextLayout::FormatRange> formats = block.layout()->formats();
        QVERIFY(!formats.isEmpty());
        block = block.next();
    }
}

void TestCppSyntaxHighlighter::testPreprocessor()
{
    QTextDocument doc;
    CppSyntaxHighlighter highlighter(&doc);
    doc.setPlainText("#define MAX 100\n#ifdef DEBUG\n#endif");
    
    QTextBlock block = doc.begin();
    while (block.isValid()) {
        QList<QTextLayout::FormatRange> formats = block.layout()->formats();
        QVERIFY(!formats.isEmpty());
        block = block.next();
    }
}

void TestCppSyntaxHighlighter::testInclude()
{
    QTextDocument doc;
    CppSyntaxHighlighter highlighter(&doc);
    doc.setPlainText("#include <iostream>\n#include \"myheader.h\"");
    
    QTextBlock block = doc.begin();
    while (block.isValid()) {
        QList<QTextLayout::FormatRange> formats = block.layout()->formats();
        QVERIFY(!formats.isEmpty());
        block = block.next();
    }
}

void TestCppSyntaxHighlighter::testNumbers()
{
    QTextDocument doc;
    CppSyntaxHighlighter highlighter(&doc);
    doc.setPlainText("int x = 12345;");
    
    QTextBlock block = doc.begin();
    QList<QTextLayout::FormatRange> formats = block.layout()->formats();
    bool foundNumber = false;
    for (const auto &range : formats) {
        if (range.start == 8 && range.length == 5) {
            foundNumber = true;
            break;
        }
    }
    QVERIFY(foundNumber);
}
