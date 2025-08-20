#include "test_shellsyntaxhighlighter.h"
#include "../src/app/shellsyntaxhighlighter.h"
#include "../src/app/syntaxtheme.h"
#include <QTextDocument>
#include <QTextCursor>
#include <QTextCharFormat>
#include <QTest>


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

    QTextBlock block = doc.firstBlock();
    QTextLayout *layout = block.layout();
    QList<QTextLayout::FormatRange> formats = layout->formats();
    QVERIFY(!formats.isEmpty());

    QColor color = formats.first().format.foreground().color();
    QColor comment = theme.commentColor;
    QCOMPARE(color,comment);
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


    QTextBlock block = doc.firstBlock();
    QTextLayout *layout = block.layout();
    QList<QTextLayout::FormatRange> formats = layout->formats();
    QVERIFY(!formats.isEmpty());

    QColor color = formats.first().format.foreground().color();
    QColor comment = theme.stringColor;
    QCOMPARE(color,comment);
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

    QTextBlock block = doc.firstBlock();
    QTextLayout *layout = block.layout();
    QList<QTextLayout::FormatRange> formats = layout->formats();
    QVERIFY(!formats.isEmpty());

    QColor color = formats.first().format.foreground().color();
    QColor comment = theme.stringColor;
    QCOMPARE(color,comment);

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

    QTextBlock block = doc.lastBlock();
    QTextLayout *layout = block.layout();
    QList<QTextLayout::FormatRange> formats = layout->formats();
    QVERIFY(!formats.isEmpty());

    QColor color = formats.last().format.foreground().color();
    QColor comment = theme.stringColor;
    QCOMPARE(color,comment);
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

    QTextBlock block = doc.firstBlock();
    QTextLayout *layout = block.layout();
    QList<QTextLayout::FormatRange> formats = layout->formats();
    QVERIFY(!formats.isEmpty());

    QColor color = formats.first().format.foreground().color();
    QColor comment = theme.commentColor;
    QCOMPARE(color,comment);
}
