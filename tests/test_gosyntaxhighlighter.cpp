#include "test_gosyntaxhighlighter.h"
#include <QTextDocument>

void TestGoSyntaxHighlighter::initTestCase() {
    m_theme = new SyntaxTheme(this);
}

void TestGoSyntaxHighlighter::cleanupTestCase() {
    delete m_theme;
}

void TestGoSyntaxHighlighter::testKeywords() {
    GoSyntaxHighlighter highlighter(nullptr, m_theme);
    
    // Check "package"
    auto ranges = highlighter.highlightLine("package main");
    bool found = false;
    for (const auto &r : ranges) {
        if (r.start == 0 && r.length == 7 && r.format.foreground().color() == m_theme->keywordColor) {
            found = true;
            break;
        }
    }
    QVERIFY(found);
    
    // Check "func"
    ranges = highlighter.highlightLine("func main() {");
    found = false;
    for (const auto &r : ranges) {
        if (r.start == 0 && r.length == 4 && r.format.foreground().color() == m_theme->keywordColor) {
            found = true;
            break;
        }
    }
    QVERIFY(found);
}

void TestGoSyntaxHighlighter::testTypes() {
    GoSyntaxHighlighter highlighter(nullptr, m_theme);
    
    auto ranges = highlighter.highlightLine("var i int");
    bool found = false;
    for (const auto &r : ranges) {
        if (r.start == 6 && r.length == 3 && r.format.foreground().color() == m_theme->keywordColor) {
            found = true;
            break;
        }
    }
    QVERIFY(found);
}

void TestGoSyntaxHighlighter::testConstants() {
    GoSyntaxHighlighter highlighter(nullptr, m_theme);
    
    auto ranges = highlighter.highlightLine("const a = true");
    bool found = false;
    for (const auto &r : ranges) {
        if (r.start == 10 && r.length == 4 && r.format.foreground().color() == m_theme->keywordColor) {
            found = true;
            break;
        }
    }
    QVERIFY(found);
}

void TestGoSyntaxHighlighter::testStrings() {
    GoSyntaxHighlighter highlighter(nullptr, m_theme);
    
    auto ranges = highlighter.highlightLine("s := \"hello\"");
    bool found = false;
    for (const auto &r : ranges) {
        if (r.start == 5 && r.length == 7 && r.format.foreground().color() == m_theme->stringColor) {
            found = true;
            break;
        }
    }
    QVERIFY(found);
}

void TestGoSyntaxHighlighter::testRawStrings() {
    GoSyntaxHighlighter highlighter(nullptr, m_theme);
    
    auto ranges = highlighter.highlightLine("s := `raw` ");
    bool found = false;
    for (const auto &r : ranges) {
        if (r.start == 5 && r.length == 5 && r.format.foreground().color() == m_theme->stringColor) {
            found = true;
            break;
        }
    }
    QVERIFY(found);
}

void TestGoSyntaxHighlighter::testComments() {
    GoSyntaxHighlighter highlighter(nullptr, m_theme);
    
    auto ranges = highlighter.highlightLine("// comment");
    bool found = false;
    for (const auto &r : ranges) {
        if (r.start == 0 && r.length == 10 && r.format.foreground().color() == m_theme->commentColor) {
            found = true;
            break;
        }
    }
    QVERIFY(found);
}

void TestGoSyntaxHighlighter::testMultilineComments() {
    GoSyntaxHighlighter highlighter(nullptr, m_theme);
    
    auto ranges = highlighter.highlightLine("/* multiline */");
    bool found = false;
    for (const auto &r : ranges) {
        if (r.start == 0 && r.length == 15 && r.format.foreground().color() == m_theme->commentColor) {
            found = true;
            break;
        }
    }
    QVERIFY(found);
}

void TestGoSyntaxHighlighter::testMultiLineBlockStates() {
    QTextDocument doc;
    GoSyntaxHighlighter highlighter(&doc, m_theme);

    // Multi-line comment across blocks
    doc.setPlainText("/* line 1\n   line 2\n   line 3 */\nvar i int");
    highlighter.rehighlight();
    
    // Check line 1
    QTextBlock block = doc.begin();
    QVERIFY(block.isValid());
    QCOMPARE(block.layout()->formats().size(), 1);
    QCOMPARE(block.layout()->formats().at(0).format.foreground().color(), m_theme->commentColor);

    // Check line 2
    block = block.next();
    QVERIFY(block.isValid());
    QCOMPARE(block.layout()->formats().size(), 1);
    QCOMPARE(block.layout()->formats().at(0).format.foreground().color(), m_theme->commentColor);

    // Check line 4 (code after comment)
    block = block.next().next();
    QVERIFY(block.isValid());
    // "var i int" -> "var" and "int" should be highlighted as keywords
    QCOMPARE(block.layout()->formats().size(), 2); 
    QCOMPARE(block.layout()->formats().at(0).format.foreground().color(), m_theme->keywordColor); // "var"
    QCOMPARE(block.layout()->formats().at(1).format.foreground().color(), m_theme->keywordColor); // "int"
}

void TestGoSyntaxHighlighter::testPerformance() {
    QString largeCode;
    for (int i = 0; i < 100; ++i) {
        largeCode += "func test" + QString::number(i) + "() {\n";
        largeCode += "    var i int = " + QString::number(i) + "\n";
        largeCode += "    if i > 0 {\n";
        largeCode += "        return\n";
        largeCode += "    }\n";
        largeCode += "}\n\n";
    }
    
    QBENCHMARK {
        QTextDocument doc(largeCode);
        GoSyntaxHighlighter highlighter(&doc, m_theme);
    }
}
