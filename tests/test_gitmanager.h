#ifndef TEST_GITMANAGER_H
#define TEST_GITMANAGER_H

#include <QObject>

class TestGitManager : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void testBranchName();
};

#endif // TEST_GITMANAGER_H
