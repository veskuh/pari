#include "test_cppsyntaxhighlighter.h"
#include "cppsyntaxhighlighter.h"
#include <QTextDocument>
#include <QTextCursor>
#include <QTextCharFormat>

// Helper function to check the format of a specific range of text
static bool checkFormat(const QTextDocument &doc, int start, int length, const QTextCharFormat &expectedFormat) {
    QTextCursor cursor(doc.findBlock(start));
    cursor.setPosition(start);
    cursor.movePosition(QTextCursor::Right, QTextCursor::KeepAnchor, length);
    return cursor.charFormat().foreground() == expectedFormat.foreground();
}

void TestCppSyntaxHighlighter::testKeywords()
{
    QTextDocument doc;
    CppSyntaxHighlighter highlighter(&doc);
    QTextCharFormat keywordFormat;
    keywordFormat.setForeground(QColor(255, 121, 198));

    doc.setPlainText("class MyClass { int x; }");
    highlighter.rehighlight();

    QVERIFY(checkFormat(doc, 0, 5, keywordFormat));  // class
    QVERIFY(checkFormat(doc, 16, 3, keywordFormat)); // int
}

void TestCppSyntaxHighlighter::testSingleLineComment()
{
    QTextDocument doc;
    CppSyntaxHighlighter highlighter(&doc);
    QTextCharFormat commentFormat;
    commentFormat.setForeground(QColor(98, 114, 164));

    doc.setPlainText("// class int");
    highlighter.rehighlight();

    QVERIFY(checkFormat(doc, 0, 11, commentFormat));
}

void TestCppSyntaxHighlighter::testMultiLineComment()
{
    QTextDocument doc;
    CppSyntaxHighlighter highlighter(&doc);
    QTextCharFormat commentFormat;
    commentFormat.setForeground(QColor(98, 114, 164));

    doc.setPlainText("/* class \n int */");
    highlighter.rehighlight();

    QVERIFY(checkFormat(doc, 0, 9, commentFormat)); // "/* class \n"
    QVERIFY(checkFormat(doc, 10, 5, commentFormat)); // " int */"
}

void TestCppSyntaxHighlighter::testString()
{
    QTextDocument doc;
    CppSyntaxHighlighter highlighter(&doc);
    QTextCharFormat stringFormat;
    stringFormat.setForeground(QColor(241, 250, 140));

    doc.setPlainText("\"class int\"");
    highlighter.rehighlight();

    QVERIFY(checkFormat(doc, 0, 11, stringFormat));
}

void TestCppSyntaxHighlighter::testInclude()
{
    QTextDocument doc;
    CppSyntaxHighlighter highlighter(&doc);
    QTextCharFormat includeFormat;
    includeFormat.setForeground(QColor(255, 184, 108));

    doc.setPlainText("#include <iostream>");
    highlighter.rehighlight();

    QVERIFY(checkFormat(doc, 0, 19, includeFormat));
}

void TestCppSyntaxHighlighter::testMacro()
{
    QTextDocument doc;
    CppSyntaxHighlighter highlighter(&doc);
    QTextCharFormat macroFormat;
    macroFormat.setForeground(QColor(255, 184, 108));

    doc.setPlainText("#define MAX_SIZE 100");
    highlighter.rehighlight();

    QVERIFY(checkFormat(doc, 0, 20, macroFormat));
}

void TestCppSyntaxHighlighter::testMixed()
{
    QTextDocument doc;
    CppSyntaxHighlighter highlighter(&doc);
    QTextCharFormat keywordFormat, commentFormat, stringFormat;
    keywordFormat.setForeground(QColor(255, 121, 198));
    commentFormat.setForeground(QColor(98, 114, 164));
    stringFormat.setForeground(QColor(241, 250, 140));

    doc.setPlainText("if (true) { /* comment */\n auto str = \"string\"; } // else");
    highlighter.rehighlight();

    QVERIFY(checkFormat(doc, 0, 2, keywordFormat)); // if
    QVERIFY(checkFormat(doc, 14, 13, commentFormat)); // /* comment */
    QVERIFY(checkFormat(doc, 30, 8, stringFormat));  // "string"
    QVERIFY(checkFormat(doc, 42, 7, commentFormat)); // // else
}

void TestCppSyntaxHighlighter::testMultiLineCommentState()
{
    QTextDocument doc;
    CppSyntaxHighlighter highlighter(&doc);
    QTextCharFormat commentFormat;
    commentFormat.setForeground(QColor(98, 114, 164));

    doc.setPlainText("/* multi-line \n comment */");
    highlighter.rehighlight();

    QVERIFY(doc.findBlockByNumber(0).userState() == 1); // InComment
    QVERIFY(checkFormat(doc, 0, 14, commentFormat));
    QVERIFY(doc.findBlockByNumber(1).userState() == 0); // Normal
    QVERIFY(checkFormat(doc, 14, 9, commentFormat));
}

void TestCppSyntaxHighlighter::testMultiLineStringState()
{
    QTextDocument doc;
    CppSyntaxHighlighter highlighter(&doc);
    QTextCharFormat stringFormat;
    stringFormat.setForeground(QColor(241, 250, 140));

    doc.setPlainText("\"multi-line\\\nstring\"");
    highlighter.rehighlight();

    QVERIFY(doc.findBlockByNumber(0).userState() == 2); // InString
    QVERIFY(checkFormat(doc, 0, 13, stringFormat));
    QVERIFY(doc.findBlockByNumber(1).userState() == 0); // Normal
    QVERIFY(checkFormat(doc, 13, 7, stringFormat));
}

void TestCppSyntaxHighlighter::testNestedConstructs()
{
    QTextDocument doc;
    CppSyntaxHighlighter highlighter(&doc);
    QTextCharFormat stringFormat, commentFormat;
    stringFormat.setForeground(QColor(241, 250, 140));
    commentFormat.setForeground(QColor(98, 114, 164));

    // Test for " in a comment
    doc.setPlainText("/* \"this is not a string\" */");
    highlighter.rehighlight();
    QVERIFY(checkFormat(doc, 0, 28, commentFormat));

    // Test for /* in a string
    doc.setPlainText("\"this is not a /* comment */\"");
    highlighter.rehighlight();
    QVERIFY(checkFormat(doc, 0, 29, stringFormat));

    // Test for string in a single-line comment
    doc.setPlainText("// item->description = \"<p><b>Changes...</b></p>\";");
    highlighter.rehighlight();
    QVERIFY(checkFormat(doc, 0, doc.toPlainText().length(), commentFormat));

    // Test for string in a multi-line comment
    doc.setPlainText("/* \"sw\" */");
    highlighter.rehighlight();
    QVERIFY(checkFormat(doc, 0, 10, commentFormat));
}
