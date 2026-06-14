#include "test_kotlinsyntaxhighlighter.h"
#include "kotlinsyntaxhighlighter.h"
#include "syntaxtheme.h"
#include <QTextDocument>

void TestKotlinSyntaxHighlighter::initTestCase()
{
}

void TestKotlinSyntaxHighlighter::cleanupTestCase()
{
}

void TestKotlinSyntaxHighlighter::testKeywords()
{
    SyntaxTheme theme;
    theme.keywordColor = QColor("blue");
    KotlinSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("fun main() { val x = 1 }");
    bool foundFun = false;
    bool foundVal = false;
    for (const auto &r : ranges) {
        if (r.start == 0 && r.length == 3) {
            foundFun = true;
        }
        if (r.start == 13 && r.length == 3) {
            foundVal = true;
        }
    }
    QVERIFY(foundFun);
    QVERIFY(foundVal);
}

void TestKotlinSyntaxHighlighter::testAnnotations()
{
    SyntaxTheme theme;
    theme.preprocessorColor = QColor("purple");
    KotlinSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("@JvmStatic");
    bool found = false;
    for (const auto &r : ranges) {
        if (r.length == 10) {
            found = true;
            break;
        }
    }
    QVERIFY(found);
}

void TestKotlinSyntaxHighlighter::testStrings()
{
    SyntaxTheme theme;
    theme.stringColor = QColor("red");
    KotlinSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("val s = \"hello\"");
    bool found = false;
    for (const auto &r : ranges) {
        if (r.length == 7) {
            found = true;
            break;
        }
    }
    QVERIFY(found);
}

void TestKotlinSyntaxHighlighter::testComments()
{
    SyntaxTheme theme;
    theme.commentColor = QColor("green");
    KotlinSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("// kotlin comment");
    QVERIFY(!ranges.isEmpty());
}

void TestKotlinSyntaxHighlighter::testMultilineComments()
{
    SyntaxTheme theme;
    theme.commentColor = QColor("green");
    KotlinSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("/* kotlin multi-line \n comment */");
    QVERIFY(!ranges.isEmpty());
}

void TestKotlinSyntaxHighlighter::testPerformance()
{
    SyntaxTheme theme;
    theme.keywordColor = QColor("blue");
    theme.stringColor = QColor("red");
    theme.commentColor = QColor("green");
    theme.preprocessorColor = QColor("purple");

    QString largeText;
    for (int i = 0; i < 1000; ++i) {
        largeText += "class Test {\n  fun main(args: Array<String>) {\n    println(\"Hello World\")\n    // comment\n  }\n}\n";
    }

    QBENCHMARK {
        QTextDocument doc(largeText);
        KotlinSyntaxHighlighter highlighter(&doc, &theme);
    }
}

void TestKotlinSyntaxHighlighter::testMultiLineBlockStates()
{
    SyntaxTheme theme;
    theme.commentColor = QColor("green");
    theme.keywordColor = QColor("blue");

    QTextDocument doc;
    KotlinSyntaxHighlighter highlighter(&doc, &theme);

    // Multi-line comment across blocks, ending with */ at the start of a line
    doc.setPlainText("/* line 1\n*/\nclass Main");
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
    // "class" -> keyword
    QCOMPARE(block.layout()->formats().size(), 1);
    QCOMPARE(block.layout()->formats().at(0).format.foreground().color(), theme.keywordColor);
}
