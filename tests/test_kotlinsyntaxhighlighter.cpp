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
