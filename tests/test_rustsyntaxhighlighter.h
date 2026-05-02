#ifndef TEST_RUSTSYNTAXHIGHLIGHTER_H
#define TEST_RUSTSYNTAXHIGHLIGHTER_H

#include <QtTest>

class TestRustSyntaxHighlighter : public QObject
{
    Q_OBJECT
private slots:
    void initTestCase();
    void testKeywords();
    void testTypes();
    void testStrings();
    void testComments();
    void testMultilineComments();
    void testAttributes();
    void testPerformance();
    void cleanupTestCase();
};

#endif // TEST_RUSTSYNTAXHIGHLIGHTER_H
