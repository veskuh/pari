#ifndef TEST_GITLOGMODEL_H
#define TEST_GITLOGMODEL_H

#include <QObject>

class TestGitLogModel : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void testParsing();
    void testEmptyLog();
    void testCommitWithoutBody();
    void testInvalidData();
    void testRoleNames();
    void testFiltering();
    void testDetailsAndLoading();
    void testParseComplexLog();
};

#endif // TEST_GITLOGMODEL_H
