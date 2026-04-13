#include "test_cppsyntaxhighlighter.h"
#include "cppsyntaxhighlighter.h"
#include "syntaxtheme.h"
#include <QTextDocument>

void TestCppSyntaxHighlighter::initTestCase()
{
}

void TestCppSyntaxHighlighter::cleanupTestCase()
{
}

void TestCppSyntaxHighlighter::testKeywords()
{
    SyntaxTheme theme;
    theme.keywordColor = QColor("blue");
    CppSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("int main()");
    bool found = false;
    for (const auto &r : ranges) {
        if (r.start == 0 && r.length == 3) {
            found = true;
            break;
        }
    }
    QVERIFY(found);
}

void TestCppSyntaxHighlighter::testStrings()
{
    SyntaxTheme theme;
    theme.stringColor = QColor("red");
    CppSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("const char* s = \"hello\";");
    bool found = false;
    for (const auto &r : ranges) {
        if (r.length == 7) { // "\"hello\""
            found = true;
            break;
        }
    }
    QVERIFY(found);
}

void TestCppSyntaxHighlighter::testComments()
{
    SyntaxTheme theme;
    theme.commentColor = QColor("green");
    CppSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("// comment");
    QVERIFY(!ranges.isEmpty());
}

void TestCppSyntaxHighlighter::testMultilineComments()
{
    SyntaxTheme theme;
    theme.commentColor = QColor("green");
    CppSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("/* comment */");
    QVERIFY(!ranges.isEmpty());
}

void TestCppSyntaxHighlighter::testPreprocessor()
{
    SyntaxTheme theme;
    theme.preprocessorColor = QColor("purple");
    CppSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("#define MAX 100");
    QVERIFY(!ranges.isEmpty());
}

void TestCppSyntaxHighlighter::testInclude()
{
    SyntaxTheme theme;
    theme.preprocessorColor = QColor("purple");
    CppSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("#include <iostream>");
    QVERIFY(!ranges.isEmpty());
}

void TestCppSyntaxHighlighter::testNumbers()
{
    // CppSyntaxHighlighter doesn't seem to have a dedicated rule for numbers yet in the code I read
    // But I will keep the test case to ensure it doesn't crash
    SyntaxTheme theme;
    CppSyntaxHighlighter highlighter(nullptr, &theme);
    highlighter.highlightLine("12345");
}

void TestCppSyntaxHighlighter::testPerformance()
{
    SyntaxTheme theme;
    theme.keywordColor = QColor("blue");
    theme.stringColor = QColor("red");
    theme.commentColor = QColor("green");
    theme.preprocessorColor = QColor("purple");

    QString largeText;
    for (int i = 0; i < 1000; ++i) {
        largeText += "int x = 0; // single line comment\n/* multi line \n comment */\nconst char* str = \"hello world\";\n";
    }

    QBENCHMARK {
        QTextDocument doc(largeText);
        CppSyntaxHighlighter highlighter(&doc, &theme);
    }
}
