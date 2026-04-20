#ifndef TEST_GITBLAMEMODEL_H
#define TEST_GITBLAMEMODEL_H

#include <QtTest>
#include "gitblamemodel.h"

class TestGitBlameModel : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void testParsing();
    void testClear();
    void cleanupTestCase();
};

#endif // TEST_GITBLAMEMODEL_H
