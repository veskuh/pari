#ifndef TEST_QMLSYNTAXHIGHLIGHTER_H
#define TEST_QMLSYNTAXHIGHLIGHTER_H

#include <QObject>
#include <QTest>

class TestQmlSyntaxHighlighter : public QObject
{
    Q_OBJECT

private slots:
    void testInitialState();
    void testKeywords();
    void testStrings();
    void testComments();
};

#endif // TEST_QMLSYNTAXHIGHLIGHTER_H
