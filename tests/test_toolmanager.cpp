#include "test_toolmanager.h"
#include "toolmanager.h"
#include <QSignalSpy>
#include <QDir>
#include <QDebug>
#include <QCoreApplication>
#include <QFile>
#include <QTextStream>

// Helper to expose private members for testing if needed
// Or just test through public signals.

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
    // toolmanager adds <br> for every line, echo hello outputs "hello\n"
    QCOMPARE(arguments.at(1).toString(), "hello<br><br>");
}

void TestToolManager::testFormatDiffOutput()
{
    ToolManager toolManager;
    QSignalSpy spy(&toolManager, &ToolManager::outputReady);
    
    // Create a temporary file with the diff content
    QFile file("test_diff.txt");
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream out(&file);
        out << "+added\n-removed\nnormal\n";
        file.close();
    }
    
    toolManager.runCommand("cat test_diff.txt", QDir::currentPath());
    
    // Process chain takes time
    bool signaled = false;
    for (int i = 0; i < 50; ++i) {
        if (spy.count() > 0) {
            signaled = true;
            break;
        }
        QTest::qWait(100);
    }
    
    QVERIFY(signaled);
    QList<QVariant> arguments = spy.first();
    QString output = arguments.at(1).toString();
    
    QVERIFY(output.contains("<font color=\"green\">+added</font><br>"));
    QVERIFY(output.contains("<font color=\"red\">-removed</font><br>"));
    QVERIFY(output.contains("normal<br>"));
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
