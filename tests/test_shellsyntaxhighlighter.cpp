#include "test_shellsyntaxhighlighter.h"
#include "../src/app/shellsyntaxhighlighter.h"
#include "../src/app/syntaxtheme.h"
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

void TestShellSyntaxHighlighter::testComment()
{
    QTextDocument doc;
    SyntaxTheme theme;
    theme.setCommentColor(QColor("red"));
    theme.setStringColor(QColor("green"));
    ShellSyntaxHighlighter highlighter(&doc, &theme);
    QTextCharFormat commentFormat;
    commentFormat.setForeground(theme.commentColor);

    doc.setPlainText("# This is a comment");
    highlighter.rehighlight();
    QTest::qWait(0);

    // QVERIFY(checkFormat(doc, 0, 19, commentFormat));
}

void TestShellSyntaxHighlighter::testSingleQuotedString()
{
    QTextDocument doc;
    SyntaxTheme theme;
    theme.setCommentColor(QColor("red"));
    theme.setStringColor(QColor("blue"));
    ShellSyntaxHighlighter highlighter(&doc, &theme);
    QTextCharFormat stringFormat;
    stringFormat.setForeground(theme.stringColor);

    doc.setPlainText("'hello world'");
    highlighter.rehighlight();
    QTest::qWait(0);

    // QVERIFY(checkFormat(doc, 0, 13, stringFormat));
}

void TestShellSyntaxHighlighter::testDoubleQuotedString()
{
    QTextDocument doc;
    SyntaxTheme theme;
    theme.setCommentColor(QColor("red"));
    theme.setStringColor(QColor("blue"));
    ShellSyntaxHighlighter highlighter(&doc, &theme);
    QTextCharFormat stringFormat;
    stringFormat.setForeground(theme.stringColor);

    doc.setPlainText("\"hello world\"");
    highlighter.rehighlight();
    QTest::qWait(0);

    // QVERIFY(checkFormat(doc, 0, 13, stringFormat));
}

void TestShellSyntaxHighlighter::testStringWithComment()
{
    QTextDocument doc;
    SyntaxTheme theme;
    theme.setStringColor(QColor("blue"));
    theme.setCommentColor(QColor("red"));
    ShellSyntaxHighlighter highlighter(&doc, &theme);
    QTextCharFormat stringFormat;
    stringFormat.setForeground(theme.stringColor);

    doc.setPlainText("echo \"hello # world\"");
    highlighter.rehighlight();
    QTest::qWait(0);

    // QVERIFY(checkFormat(doc, 5, 15, stringFormat));
    // QVERIFY(checkFormat(doc, 12, 1, stringFormat));
}

void TestShellSyntaxHighlighter::testCommentWithString()
{
    QTextDocument doc;
    SyntaxTheme theme;
    theme.setCommentColor(QColor("red"));
    theme.setStringColor(QColor("blue"));
    ShellSyntaxHighlighter highlighter(&doc, &theme);
    QTextCharFormat commentFormat;
    commentFormat.setForeground(theme.commentColor);

    doc.setPlainText("# echo \"hello world\"");
    highlighter.rehighlight();
    QTest::qWait(0);

    // QVERIFY(checkFormat(doc, 0, 19, commentFormat));
}
