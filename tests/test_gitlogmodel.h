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
};

#endif // TEST_GITLOGMODEL_H
