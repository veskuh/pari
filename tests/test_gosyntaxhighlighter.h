#ifndef TEST_GOSYNTAXHIGHLIGHTER_H
#define TEST_GOSYNTAXHIGHLIGHTER_H

#include <QObject>
#include <QtTest>
#include "gosyntaxhighlighter.h"
#include "syntaxtheme.h"

class TestGoSyntaxHighlighter : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    
    void testKeywords();
    void testTypes();
    void testConstants();
    void testStrings();
    void testRawStrings();
    void testComments();
    void testMultilineComments();
    void testPerformance();

private:
    SyntaxTheme *m_theme;
};

#endif // TEST_GOSYNTAXHIGHLIGHTER_H
