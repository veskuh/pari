#include "test_toolmanager.h"
#include "../src/app/toolmanager.h"
#include <QSignalSpy>
#include <QDir>

void TestToolManager::testRunCommand()
{
    ToolManager toolManager;
    QSignalSpy spy(&toolManager, &ToolManager::outputReady);

    toolManager.runCommand("echo hello", QDir::currentPath());

    QVERIFY(spy.wait());
    QCOMPARE(spy.count(), 1);
    QList<QVariant> arguments = spy.takeFirst();
    QCOMPARE(arguments.at(0).toString(), "echo hello");
    QCOMPARE(arguments.at(1).toString(), "hello<br><br>");
}
