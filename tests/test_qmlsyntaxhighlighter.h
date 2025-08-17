#ifndef TEST_QMLSYNTAXHIGHLIGHTER_H
#define TEST_QMLSYNTAXHIGHLIGHTER_H

#include <QObject>
#include <QTest>

#include "app/syntaxtheme.h"

class TestQmlSyntaxHighlighter : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void testInitialState();
    void testKeywords();
    void testStrings();
    void testComments();

private:
    SyntaxTheme *m_theme;
};

#endif // TEST_QMLSYNTAXHIGHLIGHTER_H
