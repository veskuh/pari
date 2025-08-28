#include "test_llm.h"
#include <QtTest>
#include <QSignalSpy>
#include "llm.h"
#include "settings.h"

void TestLlm::init()
{
    // Not much to do here for now
}

void TestLlm::cleanup()
{
    // Clean up settings after each test
    QSettings settings("veskuh.net", "Pari");
    settings.clear();
}

void TestLlm::testSendPromptAddsToLog()
{
    Settings settings;
    Llm llm(&settings);
    QSignalSpy spy(&llm, &Llm::chatLogChanged);

    llm.sendPrompt("Test prompt");

    QCOMPARE(spy.count(), 1);
    const QStringList log = llm.chatLog();
    QCOMPARE(log.size(), 1);
    QVERIFY(log.first().contains("USER: Test prompt"));
}

void TestLlm::testSuccessfulResponseAddsToLog()
{
    // To be implemented
}

void TestLlm::testErrorResponseAddsToLog()
{
    // To be implemented
}

void TestLlm::testSettingsChangeAddsToLog()
{
    Settings settings;
    Llm llm(&settings);
    QSignalSpy spy(&llm, &Llm::chatLogChanged);

    settings.setOllamaModel("new-test-model");

    QCOMPARE(spy.count(), 1);
    const QStringList log = llm.chatLog();
    QCOMPARE(log.size(), 1);
    QVERIFY(log.first().contains("INFO: Settings changed"));
    QVERIFY(log.first().contains("new-test-model"));
}
