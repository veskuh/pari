#ifndef TEST_JAVASYNTAXHIGHLIGHTER_H
#define TEST_JAVASYNTAXHIGHLIGHTER_H

#include <QtTest>

class TestJavaSyntaxHighlighter : public QObject
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

#endif // TEST_JAVASYNTAXHIGHLIGHTER_H
