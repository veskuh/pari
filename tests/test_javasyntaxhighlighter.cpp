#include "test_javasyntaxhighlighter.h"
#include "javasyntaxhighlighter.h"
#include "syntaxtheme.h"
#include <QTextDocument>

void TestJavaSyntaxHighlighter::initTestCase()
{
}

void TestJavaSyntaxHighlighter::cleanupTestCase()
{
}

void TestJavaSyntaxHighlighter::testKeywords()
{
    SyntaxTheme theme;
    theme.keywordColor = QColor("blue");
    JavaSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("public class Main");
    bool foundPublic = false;
    bool foundClass = false;
    for (const auto &r : ranges) {
        if (r.start == 0 && r.length == 6) {
            foundPublic = true;
        }
        if (r.start == 7 && r.length == 5) {
            foundClass = true;
        }
    }
    QVERIFY(foundPublic);
    QVERIFY(foundClass);
}

void TestJavaSyntaxHighlighter::testAnnotations()
{
    SyntaxTheme theme;
    theme.preprocessorColor = QColor("purple");
    JavaSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("@Override");
    bool found = false;
    for (const auto &r : ranges) {
        if (r.length == 9) {
            found = true;
            break;
        }
    }
    QVERIFY(found);
}

void TestJavaSyntaxHighlighter::testStrings()
{
    SyntaxTheme theme;
    theme.stringColor = QColor("red");
    JavaSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("String s = \"hello\";");
    bool found = false;
    for (const auto &r : ranges) {
        if (r.length == 7) { // "\"hello\""
            found = true;
            break;
        }
    }
    QVERIFY(found);
}

void TestJavaSyntaxHighlighter::testComments()
{
    SyntaxTheme theme;
    theme.commentColor = QColor("green");
    JavaSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("// java comment");
    QVERIFY(!ranges.isEmpty());
}

void TestJavaSyntaxHighlighter::testMultilineComments()
{
    SyntaxTheme theme;
    theme.commentColor = QColor("green");
    JavaSyntaxHighlighter highlighter(nullptr, &theme);
    
    auto ranges = highlighter.highlightLine("/* java multi-line \n comment */");
    QVERIFY(!ranges.isEmpty());
}

void TestJavaSyntaxHighlighter::testPerformance()
{
    SyntaxTheme theme;
    theme.keywordColor = QColor("blue");
    theme.stringColor = QColor("red");
    theme.commentColor = QColor("green");
    theme.preprocessorColor = QColor("purple");

    QString largeText;
    for (int i = 0; i < 1000; ++i) {
        largeText += "public class Test {\n  public static void main(String[] args) {\n    System.out.println(\"Hello World\");\n    // comment\n  }\n}\n";
    }

    QBENCHMARK {
        QTextDocument doc(largeText);
        JavaSyntaxHighlighter highlighter(&doc, &theme);
    }
}

void TestJavaSyntaxHighlighter::testMultiLineBlockStates()
{
    SyntaxTheme theme;
    theme.commentColor = QColor("green");
    theme.keywordColor = QColor("blue");

    QTextDocument doc;
    JavaSyntaxHighlighter highlighter(&doc, &theme);

    // Multi-line comment across blocks, ending with */ at the start of a line
    doc.setPlainText("/* line 1\n*/\npublic class Main");
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
    // "public class" -> both are keywords
    QCOMPARE(block.layout()->formats().size(), 2);
    QCOMPARE(block.layout()->formats().at(0).format.foreground().color(), theme.keywordColor);
}
