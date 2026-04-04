#ifndef TEST_BUILDMANAGER_H
#define TEST_BUILDMANAGER_H

#include <QObject>

class TestBuildManager : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void testExecuteCommand();
    void testExecuteCommandWithError();
};

#endif // TEST_BUILDMANAGER_H
