#include "test_swiftsyntaxhighlighter.h"
#include "swiftsyntaxhighlighter.h"
#include "syntaxtheme.h"
#include <QTextDocument>

void TestSwiftSyntaxHighlighter::initTestCase()
{
}

void TestSwiftSyntaxHighlighter::cleanupTestCase()
{
}

void TestSwiftSyntaxHighlighter::testKeywords()
{
    SyntaxTheme theme;
    theme.keywordColor = QColor("blue");
    SwiftSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("func main()");
    bool found = false;
    for (const auto &r : ranges) {
        if (r.start == 0 && r.length == 4) { // "func"
            found = true;
            break;
        }
    }
    QVERIFY(found);
}

void TestSwiftSyntaxHighlighter::testStrings()
{
    SyntaxTheme theme;
    theme.stringColor = QColor("red");
    SwiftSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("let s = \"hello\"");
    bool found = false;
    for (const auto &r : ranges) {
        if (r.length == 7) { // "\"hello\""
            found = true;
            break;
        }
    }
    QVERIFY(found);
}

void TestSwiftSyntaxHighlighter::testComments()
{
    SyntaxTheme theme;
    theme.commentColor = QColor("green");
    SwiftSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("// comment");
    QVERIFY(!ranges.isEmpty());
}

void TestSwiftSyntaxHighlighter::testMultilineComments()
{
    SyntaxTheme theme;
    theme.commentColor = QColor("green");
    SwiftSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("/* comment */");
    QVERIFY(!ranges.isEmpty());
}

void TestSwiftSyntaxHighlighter::testTypes()
{
    SyntaxTheme theme;
    theme.preprocessorColor = QColor("purple");
    SwiftSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("let x: Int = 0");
    bool found = false;
    for (const auto &r : ranges) {
        if (r.length == 3) { // "Int"
            found = true;
            break;
        }
    }
    QVERIFY(found);
}

void TestSwiftSyntaxHighlighter::testAttributes()
{
    SyntaxTheme theme;
    theme.preprocessorColor = QColor("purple");
    SwiftSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("@objc class MyClass {}");
    bool found = false;
    for (const auto &r : ranges) {
        if (r.length == 5) { // "@objc"
            found = true;
            break;
        }
    }
    QVERIFY(found);
}

void TestSwiftSyntaxHighlighter::testMultiLineBlockStates()
{
    SyntaxTheme theme;
    theme.commentColor = QColor("green");
    theme.keywordColor = QColor("blue");

    QTextDocument doc;
    SwiftSyntaxHighlighter highlighter(&doc, &theme);

    // Multi-line comment across blocks, ending with */ at the start of a line
    doc.setPlainText("/* line 1\n*/\nfunc test()");
    highlighter.rehighlight();

    // Check line 1 (starts the comment)
    QTextBlock block = doc.begin();
    QVERIFY(block.isValid());
    QCOMPARE(block.layout()->formats().size(), 1);
    QCOMPARE(block.layout()->formats().at(0).format.foreground().color(), theme.commentColor);

    // Check line 2 (ends the comment with */)
    block = block.next();
    QVERIFY(block.isValid());
    QCOMPARE(block.layout()->formats().size(), 1);
    QCOMPARE(block.layout()->formats().at(0).format.foreground().color(), theme.commentColor);

    // Check line 3 (should be highlighted as code, not comment)
    block = block.next();
    QVERIFY(block.isValid());
    // "func" -> keyword
    QCOMPARE(block.layout()->formats().size(), 1);
    QCOMPARE(block.layout()->formats().at(0).format.foreground().color(), theme.keywordColor);
}
