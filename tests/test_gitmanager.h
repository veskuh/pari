#ifndef TEST_GITMANAGER_H
#define TEST_GITMANAGER_H

#include <QObject>
#include <QTest>

class TestGitManager : public QObject
{
    Q_OBJECT

private slots:
    void testBranchName();
};

#endif // TEST_GITMANAGER_H
