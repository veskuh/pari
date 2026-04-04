#include "test_buildmanager.h"
#include "buildmanager.h"
#include <QtTest>
#include <QSignalSpy>

void TestBuildManager::initTestCase()
{
}

void TestBuildManager::cleanupTestCase()
{
}

void TestBuildManager::testExecuteCommand()
{
    BuildManager buildManager;
    QSignalSpy spy(&buildManager, &BuildManager::finished);

    buildManager.executeCommand("echo hello", "");

    QVERIFY(spy.wait());
    QCOMPARE(spy.count(), 1);
    
    QTest::qWait(100);
}

void TestBuildManager::testExecuteCommandWithError()
{
    BuildManager buildManager;
    QSignalSpy spy(&buildManager, &BuildManager::errorReady);

    // Run a non-existent command
    buildManager.executeCommand("non_existent_command_12345", "");

    QVERIFY(spy.wait());
    QCOMPARE(spy.count(), 1);
    
    QTest::qWait(100);
}
