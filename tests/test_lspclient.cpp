#include "test_lspclient.h"
#include <QtTest>
#include "../src/lspclient.h"

void TestLspClient::testStartServer()
{
    LspClient client;
    client.startServer(QDir::currentPath());
    QTest::qWait(100); // Wait for the process to start
    QVERIFY(client.isServerRunning());
}

void TestLspClient::testProjectSwitching()
{
    LspClient client;
    QDir dir;
    dir.mkpath("/tmp/project1");
    client.startServer("/tmp/project1");
    QTest::qWait(100);
    QVERIFY(client.isServerRunning());
    QCOMPARE(client.projectPath(), "/tmp/project1");

    dir.mkpath("/tmp/project2");
    client.startServer("/tmp/project2");
    QTest::qWait(100);
    QVERIFY(client.isServerRunning());
    QCOMPARE(client.projectPath(), "/tmp/project2");
}

#include "test_lspclient.moc"
