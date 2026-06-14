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

void TestCppSyntaxHighlighter::testMultiLineBlockStates()
{
    SyntaxTheme theme;
    theme.commentColor = QColor("green");
    theme.keywordColor = QColor("blue");

    QTextDocument doc;
    CppSyntaxHighlighter highlighter(&doc, &theme);

    // Multi-line comment across blocks, ending with */ at the start of a line
    doc.setPlainText("/* line 1\n*/\nint main()");
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
    // "int" is keyword, "main()" is not
    QCOMPARE(block.layout()->formats().size(), 1);
    QCOMPARE(block.layout()->formats().at(0).format.foreground().color(), theme.keywordColor);
}

