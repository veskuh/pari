#include "test_syntaxhighlighterprovider.h"
#include <QTextDocument>
#include <QQuickTextDocument>

void TestSyntaxHighlighterProvider::initTestCase()
{
    m_settings = new Settings(this);
    m_provider = new SyntaxHighlighterProvider(this);
    m_provider->setSettings(m_settings);
}

void TestSyntaxHighlighterProvider::cleanupTestCase()
{
}

void TestSyntaxHighlighterProvider::testSupportedExtensions()
{
    QStringList exts = SyntaxHighlighterProvider::supportedExtensions();
    QVERIFY(exts.contains("cpp"));
    QVERIFY(exts.contains("h"));
    QVERIFY(exts.contains("js"));
    QVERIFY(exts.contains("qml"));
    QVERIFY(exts.contains("md"));
    QVERIFY(exts.contains("swift"));
    QVERIFY(exts.contains("java"));
    QVERIFY(exts.contains("kt"));
    QVERIFY(exts.contains("rs"));
    QVERIFY(exts.contains("sh"));
    QVERIFY(exts.contains("txt"));
}

void TestSyntaxHighlighterProvider::testSupportedFileNames()
{
    QStringList names = SyntaxHighlighterProvider::supportedFileNames();
    QVERIFY(names.contains("Makefile"));
    QVERIFY(names.contains("CMakeLists.txt"));
}

void TestSyntaxHighlighterProvider::testAttachHighlighter()
{
    // We verify the logic that attaches doesn't crash and returns if doc is null.
    m_provider->attachHighlighter(nullptr, "test.cpp"); // Should return immediately
}
