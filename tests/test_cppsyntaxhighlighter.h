#ifndef TEST_CPPSYNTAXHIGHLIGHTER_H
#define TEST_CPPSYNTAXHIGHLIGHTER_H

#include <QtTest>

class TestCppSyntaxHighlighter : public QObject
{
    Q_OBJECT
private slots:
    void initTestCase();
    void testKeywords();
    void testStrings();
    void testComments();
    void testMultilineComments();
    void testPreprocessor();
    void testNumbers();
    void testInclude();
    void testPerformance();
    void cleanupTestCase();
};

#endif // TEST_CPPSYNTAXHIGHLIGHTER_H
