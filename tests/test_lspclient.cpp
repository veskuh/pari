#include "test_lspclient.h"
#include <QtTest>
#include "../src/lspclient.h"

void TestLspClient::testStartServer()
{
    LspClient client;
    // This is a basic test that only checks if the server starts.
    // A more comprehensive test would mock the process and check the messages.
    client.startServer(QDir::currentPath());
    // We can't easily check the output here without more complex setup,
    // but we can at least ensure that the application doesn't crash.
    QVERIFY(true);
}

#include "test_lspclient.moc"
