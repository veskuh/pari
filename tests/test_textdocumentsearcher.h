#ifndef TEST_TEXTDOCUMENTSEARCHER_H
#define TEST_TEXTDOCUMENTSEARCHER_H

#include <QtTest>

class TestTextDocumentSearcher : public QObject
{
    Q_OBJECT
private slots:
    void initTestCase();
    void testFindNext();
    void testFindPrevious();
    void cleanupTestCase();
};

#endif // TEST_TEXTDOCUMENTSEARCHER_H
