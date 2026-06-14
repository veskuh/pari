#ifndef TEST_SWIFTSYNTAXHIGHLIGHTER_H
#define TEST_SWIFTSYNTAXHIGHLIGHTER_H

#include <QtTest>

class TestSwiftSyntaxHighlighter : public QObject
{
    Q_OBJECT
private slots:
    void initTestCase();
    void testKeywords();
    void testStrings();
    void testComments();
    void testMultilineComments();
    void testTypes();
    void testAttributes();
    void testMultiLineBlockStates();
    void cleanupTestCase();
};

#endif // TEST_SWIFTSYNTAXHIGHLIGHTER_H
