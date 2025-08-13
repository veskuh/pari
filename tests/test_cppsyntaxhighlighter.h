#ifndef TEST_CPPSYNTAXHIGHLIGHTER_H
#define TEST_CPPSYNTAXHIGHLIGHTER_H

#include <QObject>
#include <QTest>

class TestCppSyntaxHighlighter : public QObject
{
    Q_OBJECT
private slots:
    void testKeywords();
    void testSingleLineComment();
    void testMultiLineComment();
    void testString();
    void testInclude();
    void testMacro();
    void testMixed();
    void testMultiLineCommentState();
    void testMultiLineStringState();
    void testNestedConstructs();
};

#endif // TEST_CPPSYNTAXHIGHLIGHTER_H
