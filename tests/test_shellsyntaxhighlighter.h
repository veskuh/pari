#ifndef TEST_SHELLSYNTAXHIGHLIGHTER_H
#define TEST_SHELLSYNTAXHIGHLIGHTER_H

#include <QObject>
#include <QTest>

class TestShellSyntaxHighlighter : public QObject
{
    Q_OBJECT
private slots:
    void testComment();
    void testSingleQuotedString();
    void testDoubleQuotedString();
    void testStringWithComment();
    void testCommentWithString();
};

#endif // TEST_SHELLSYNTAXHIGHLIGHTER_H
