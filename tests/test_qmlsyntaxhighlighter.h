#ifndef TEST_QMLSYNTAXHIGHLIGHTER_H
#define TEST_QMLSYNTAXHIGHLIGHTER_H

#include <QObject>

class TestQmlSyntaxHighlighter : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void testInitialState();
    void testKeywords();
    void testStrings();
    void testComments();
    void testMultiLineBlockStates();
};

#endif // TEST_QMLSYNTAXHIGHLIGHTER_H
