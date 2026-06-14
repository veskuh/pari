#ifndef TEST_KOTLINSYNTAXHIGHLIGHTER_H
#define TEST_KOTLINSYNTAXHIGHLIGHTER_H

#include <QtTest>

class TestKotlinSyntaxHighlighter : public QObject
{
    Q_OBJECT
private slots:
    void initTestCase();
    void testKeywords();
    void testAnnotations();
    void testStrings();
    void testComments();
    void testMultilineComments();
    void testPerformance();
    void testMultiLineBlockStates();
    void cleanupTestCase();
};

#endif // TEST_KOTLINSYNTAXHIGHLIGHTER_H
