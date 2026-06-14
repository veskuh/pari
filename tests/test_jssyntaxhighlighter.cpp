#include "test_jssyntaxhighlighter.h"
#include "jssyntaxhighlighter.h"
#include "syntaxtheme.h"
#include <QTextDocument>

void TestJsSyntaxHighlighter::initTestCase()
{
}

void TestJsSyntaxHighlighter::cleanupTestCase()
{
}

void TestJsSyntaxHighlighter::testKeywords()
{
    SyntaxTheme theme;
    theme.keywordColor = QColor("blue");
    JsSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("const x = true;");
    bool foundConst = false;
    bool foundTrue = false;
    for (const auto &r : ranges) {
        if (r.start == 0 && r.length == 5) foundConst = true;
        if (r.start == 10 && r.length == 4) foundTrue = true;
    }
    QVERIFY(foundConst);
    QVERIFY(foundTrue);
}

void TestJsSyntaxHighlighter::testFunctions()
{
    SyntaxTheme theme;
    theme.preprocessorColor = QColor("purple");
    JsSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("function myFunc() { console.log(); }");
    bool foundMyFunc = false;
    bool foundLog = false;
    for (const auto &r : ranges) {
        if (r.length == 6 && r.start == 9) foundMyFunc = true;
        if (r.length == 3 && r.start == 28) foundLog = true;
    }
    QVERIFY(foundMyFunc);
    QVERIFY(foundLog);
}

void TestJsSyntaxHighlighter::testStrings()
{
    SyntaxTheme theme;
    theme.stringColor = QColor("red");
    JsSyntaxHighlighter highlighter(nullptr, &theme);
    
    // Double quotes
    auto ranges = highlighter.highlightLine("let s = \"hello\";");
    bool found = false;
    for (const auto &r : ranges) {
        if (r.length == 7) found = true;
    }
    QVERIFY(found);

    // Single quotes
    ranges = highlighter.highlightLine("let s = 'hello';");
    found = false;
    for (const auto &r : ranges) {
        if (r.length == 7) found = true;
    }
    QVERIFY(found);

    // Backticks
    ranges = highlighter.highlightLine("let s = `hello`;");
    found = false;
    for (const auto &r : ranges) {
        if (r.length == 7) found = true;
    }
    QVERIFY(found);
}

void TestJsSyntaxHighlighter::testComments()
{
    SyntaxTheme theme;
    theme.commentColor = QColor("green");
    JsSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("// comment");
    QVERIFY(!ranges.isEmpty());
}

void TestJsSyntaxHighlighter::testMultilineComments()
{
    SyntaxTheme theme;
    theme.commentColor = QColor("green");
    JsSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("/* comment */");
    QVERIFY(!ranges.isEmpty());
}

void TestJsSyntaxHighlighter::testNumbers()
{
    SyntaxTheme theme;
    theme.stringColor = QColor("red");
    JsSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("let x = 123.45;");
    bool found = false;
    for (const auto &r : ranges) {
        if (r.length == 6 && r.start == 8) found = true;
    }
    QVERIFY(found);
}

void TestJsSyntaxHighlighter::testMultiLineBlockStates()
{
    SyntaxTheme theme;
    theme.commentColor = QColor("green");
    theme.keywordColor = QColor("blue");

    QTextDocument doc;
    JsSyntaxHighlighter highlighter(&doc, &theme);

    // Multi-line comment across blocks, ending with */ at the start of a line
    doc.setPlainText("/* line 1\n*/\nconst x = 123");
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
    // "const" -> keyword, "123" -> number
    QCOMPARE(block.layout()->formats().size(), 2);
    QCOMPARE(block.layout()->formats().at(0).format.foreground().color(), theme.keywordColor);
}
