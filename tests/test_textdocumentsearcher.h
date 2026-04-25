#ifndef TEST_TEXTDOCUMENTSEARCHER_H
#define TEST_TEXTDOCUMENTSEARCHER_H

#include <QtTest>
#include "textdocumentsearcher.h"

class TestTextDocumentSearcher : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void testFindNext();
    void testFindPrevious();
    void testApplyFilter();
    void testClearFilter();
    void cleanupTestCase();
};

#endif // TEST_TEXTDOCUMENTSEARCHER_H
