#include "test_buildmanager.h"
#include "app/buildmanager.h"
#include <QtTest>
#include <QSignalSpy>

void TestBuildManager::testExecuteCommand()
{
    BuildManager buildManager;
    QSignalSpy outputSpy(&buildManager, &BuildManager::outputReady);
    QSignalSpy errorSpy(&buildManager, &BuildManager::errorReady);
    QSignalSpy finishedSpy(&buildManager, &BuildManager::finished);

    buildManager.executeCommand("echo 'hello world'", QDir::currentPath());

    QVERIFY(finishedSpy.wait());
    QCOMPARE(finishedSpy.count(), 1);
    QCOMPARE(errorSpy.count(), 0);
    QVERIFY(!outputSpy.isEmpty());

    // Collect all output signal emissions into a single string
    QString fullOutput;
    for (const auto &signalArgs : outputSpy) {
        fullOutput += signalArgs.first().toString();
    }
    QVERIFY(fullOutput.contains("hello world"));
}

void TestBuildManager::testExecuteCommandWithError()
{
    BuildManager buildManager;
    QSignalSpy outputSpy(&buildManager, &BuildManager::outputReady);
    QSignalSpy errorSpy(&buildManager, &BuildManager::errorReady);
    QSignalSpy finishedSpy(&buildManager, &BuildManager::finished);

    buildManager.executeCommand("non_existent_command_12345", QDir::currentPath());

    QVERIFY(finishedSpy.wait());
    QCOMPARE(finishedSpy.count(), 1);
    QVERIFY(!errorSpy.isEmpty());
    QVERIFY(outputSpy.isEmpty());
}
