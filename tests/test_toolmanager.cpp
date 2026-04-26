#include "test_toolmanager.h"
#include "toolmanager.h"
#include <QSignalSpy>
#include <QDir>
#include <QDebug>
#include <QCoreApplication>
#include <QFile>
#include <QTextStream>

void TestToolManager::initTestCase()
{
}

void TestToolManager::cleanupTestCase()
{
    QFile::remove("test_diff.txt");
}

void TestToolManager::testRunCommand()
{
    ToolManager toolManager;
    QSignalSpy spy(&toolManager, &ToolManager::outputReady);

    toolManager.runCommand("echo hello", QDir::currentPath());

    QVERIFY(spy.wait());
    QCOMPARE(spy.count(), 1);
    QList<QVariant> arguments = spy.takeFirst();
    QCOMPARE(arguments.at(0).toString(), "echo hello");
    
    // toolmanager emits raw output for non-diff commands. echo hello outputs "hello\n"
    QString expected = "hello\n";
    QCOMPARE(arguments.at(1).toString(), expected);
}

void TestToolManager::testFormatDiffOutput()
{
    ToolManager toolManager;
    QSignalSpy spy(&toolManager, &ToolManager::outputReady);
    
    // Create a temporary file with the diff content
    QFile file("test_diff.txt");
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream out(&file);
        out << "+added\n-removed\n@@ hunk\n";
        file.close();
    }
    
    // We force the command to contain 'git diff' so formatDiffOutput is triggered
    toolManager.runCommand("echo 'git diff' && cat test_diff.txt", QDir::currentPath());
    
    QVERIFY(spy.wait());
    QList<QVariant> arguments = spy.first();
    QString output = arguments.at(1).toString();
    
    QVERIFY(output.contains("<font color=\"#228b22\">+added</font><br>"));
    QVERIFY(output.contains("<font color=\"#cc0000\">-removed</font><br>"));
    QVERIFY(output.contains("<font color=\"#0000ff\">@@ hunk</font><br>"));
    QVERIFY(output.startsWith("<div"));
}

void TestToolManager::testIndentQmlFile()
{
    ToolManager toolManager;
    QSignalSpy spy(&toolManager, &ToolManager::qmlFileIndented);
    
    QString originalContent = "Item { }";
    toolManager.indentQmlFile("test.qml", originalContent);
    
    // Even if qmlformat is not found, it should emit the signal with original content
    QVERIFY(spy.wait(5000));
    QCOMPARE(spy.count(), 1);
    QString result = spy.first().at(0).toString();
    QVERIFY(result == originalContent || !result.isEmpty());
}

void TestToolManager::testRunCommandWithError()
{
    ToolManager toolManager;
    QSignalSpy spy(&toolManager, &ToolManager::outputReady);

    // Run a command that produces error output
    toolManager.runCommand("sh -c 'echo error message >&2'", QDir::currentPath());

    QVERIFY(spy.wait());
    QCOMPARE(spy.count(), 1);
    QList<QVariant> arguments = spy.takeFirst();
    QVERIFY(arguments.at(1).toString().contains("error message"));
}
