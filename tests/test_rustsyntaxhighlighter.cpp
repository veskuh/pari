#include "test_rustsyntaxhighlighter.h"
#include "rustsyntaxhighlighter.h"
#include "syntaxtheme.h"
#include <QTextDocument>

void TestRustSyntaxHighlighter::initTestCase()
{
}

void TestRustSyntaxHighlighter::cleanupTestCase()
{
}

void TestRustSyntaxHighlighter::testKeywords()
{
    SyntaxTheme theme;
    theme.keywordColor = QColor("blue");
    RustSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("fn main() { return; }");
    bool foundFn = false;
    bool foundReturn = false;
    for (const auto &r : ranges) {
        if (r.start == 0 && r.length == 2) foundFn = true;
        if (r.start == 12 && r.length == 6) foundReturn = true;
    }
    QVERIFY(foundFn);
    QVERIFY(foundReturn);
}

void TestRustSyntaxHighlighter::testTypes()
{
    SyntaxTheme theme;
    theme.keywordColor = QColor("blue");
    RustSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("let x: i32 = 5;");
    bool found = false;
    for (const auto &r : ranges) {
        if (r.start == 7 && r.length == 3) {
            found = true;
            break;
        }
    }
    QVERIFY(found);
}

void TestRustSyntaxHighlighter::testStrings()
{
    SyntaxTheme theme;
    theme.stringColor = QColor("red");
    RustSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("let s = \"hello\";");
    bool found = false;
    for (const auto &r : ranges) {
        if (r.length == 7) { // "\"hello\""
            found = true;
            break;
        }
    }
    QVERIFY(found);
}

void TestRustSyntaxHighlighter::testComments()
{
    SyntaxTheme theme;
    theme.commentColor = QColor("green");
    RustSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("// rust comment");
    QVERIFY(!ranges.isEmpty());
}

void TestRustSyntaxHighlighter::testMultilineComments()
{
    SyntaxTheme theme;
    theme.commentColor = QColor("green");
    RustSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("/* rust multiline comment */");
    QVERIFY(!ranges.isEmpty());
}

void TestRustSyntaxHighlighter::testAttributes()
{
    SyntaxTheme theme;
    theme.preprocessorColor = QColor("purple");
    RustSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("#[derive(Debug)]");
    QVERIFY(!ranges.isEmpty());
}

void TestRustSyntaxHighlighter::testPerformance()
{
    SyntaxTheme theme;
    theme.keywordColor = QColor("blue");
    theme.stringColor = QColor("red");
    theme.commentColor = QColor("green");
    theme.preprocessorColor = QColor("purple");

    QString largeText;
    for (int i = 0; i < 1000; ++i) {
        largeText += "fn test() { let x: i32 = 0; // single line comment\n/* multi line \n comment */\nlet str = \"hello world\"; }\n";
    }

    QBENCHMARK {
        QTextDocument doc(largeText);
        RustSyntaxHighlighter highlighter(&doc, &theme);
    }
}

void TestRustSyntaxHighlighter::testMultiLineBlockStates()
{
    SyntaxTheme theme;
    theme.commentColor = QColor("green");
    theme.keywordColor = QColor("blue");

    QTextDocument doc;
    RustSyntaxHighlighter highlighter(&doc, &theme);

    // Multi-line comment across blocks, ending with */ at the start of a line
    doc.setPlainText("/* line 1\n*/\nfn main()");
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
    // "fn" -> keyword
    QCOMPARE(block.layout()->formats().size(), 1);
    QCOMPARE(block.layout()->formats().at(0).format.foreground().color(), theme.keywordColor);
}
