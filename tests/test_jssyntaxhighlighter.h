#ifndef TEST_JSSYNTAXHIGHLIGHTER_H
#define TEST_JSSYNTAXHIGHLIGHTER_H

#include <QtTest>

class TestJsSyntaxHighlighter : public QObject
{
    Q_OBJECT
private slots:
    void initTestCase();
    void testKeywords();
    void testFunctions();
    void testStrings();
    void testComments();
    void testMultilineComments();
    void testNumbers();
    void testMultiLineBlockStates();
    void cleanupTestCase();
};

#endif // TEST_JSSYNTAXHIGHLIGHTER_H
