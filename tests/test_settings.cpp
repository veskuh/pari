#include "test_settings.h"
#include <QtTest>
#include <QSettings>
#include <QSignalSpy>
#include "app/settings.h"

void TestSettings::init()
{
    // Ensure we have a clean slate before each test
    QSettings settings("veskuh.net", "Pari");
    settings.clear();
}

void TestSettings::cleanup()
{
    // Clean up after each test
    QSettings settings("veskuh.net", "Pari");
    settings.clear();
}

void TestSettings::testDefaults()
{
    Settings settings;
    QCOMPARE(settings.ollamaUrl(), "http://localhost:11434");
    QCOMPARE(settings.ollamaModel(), "gemma3:12b");
    QCOMPARE(settings.fontFamily(), "monospace");
    QCOMPARE(settings.fontSize(), 12);
}

void TestSettings::testSettersAndGetters()
{
    Settings settings;
    settings.setOllamaUrl("http://new-url:1234");
    QCOMPARE(settings.ollamaUrl(), "http://new-url:1234");

    settings.setOllamaModel("new-model");
    QCOMPARE(settings.ollamaModel(), "new-model");

    settings.setFontFamily("Arial");
    QCOMPARE(settings.fontFamily(), "Arial");

    settings.setFontSize(20);
    QCOMPARE(settings.fontSize(), 20);
}

void TestSettings::testPersistence()
{
    // Create a Settings object, change a value, and let it be destructed.
    {
        Settings settings;
        settings.setFontSize(99);
    }

    // Create a new Settings object and check if it loads the persisted value.
    {
        Settings settings;
        QCOMPARE(settings.fontSize(), 99);
    }
}

void TestSettings::testSignals()
{
    Settings settings;
    QSignalSpy urlSpy(&settings, &Settings::ollamaUrlChanged);
    QSignalSpy modelSpy(&settings, &Settings::ollamaModelChanged);
    QSignalSpy fontSpy(&settings, &Settings::fontFamilyChanged);
    QSignalSpy sizeSpy(&settings, &Settings::fontSizeChanged);

    // Change values
    settings.setOllamaUrl("http://signal-test");
    settings.setOllamaModel("signal-model");
    settings.setFontFamily("Times New Roman");
    settings.setFontSize(42);

    // Verify signals were emitted
    QCOMPARE(urlSpy.count(), 1);
    QCOMPARE(modelSpy.count(), 1);
    QCOMPARE(fontSpy.count(), 1);
    QCOMPARE(sizeSpy.count(), 1);

    // Verify no signals on same-value set
    settings.setFontSize(42);
    QCOMPARE(sizeSpy.count(), 1);
}

void TestSettings::testAvailableModels()
{
    Settings settings;
    QSignalSpy spy(&settings, &Settings::availableModelsChanged);

    QStringList models = {"model1", "model2"};
    settings.setAvailableModels(models);

    QCOMPARE(settings.availableModels(), models);
    QCOMPARE(spy.count(), 1);

    // Verify no signal on same-value set
    settings.setAvailableModels(models);
    QCOMPARE(spy.count(), 1);
}

void TestSettings::testRecentFolders()
{
    Settings settings;
    QSignalSpy spy(&settings, &Settings::recentFoldersChanged);

    settings.addRecentFolder("/foo/bar");
    QCOMPARE(settings.recentFolders().size(), 1);
    QCOMPARE(settings.recentFolders().first(), "/foo/bar");
    QCOMPARE(spy.count(), 1);

    settings.addRecentFolder("/foo/baz");
    QCOMPARE(settings.recentFolders().size(), 2);
    QCOMPARE(settings.recentFolders().first(), "/foo/baz");
    QCOMPARE(spy.count(), 2);

    // Test adding an existing folder moves it to the front
    settings.addRecentFolder("/foo/bar");
    QCOMPARE(settings.recentFolders().size(), 2);
    QCOMPARE(settings.recentFolders().first(), "/foo/bar");
    QCOMPARE(spy.count(), 3);

    // Test that the list is capped at 10
    for (int i = 0; i < 15; ++i) {
        settings.addRecentFolder(QString("/folder%1").arg(i));
    }
    QCOMPARE(settings.recentFolders().size(), 10);
    QCOMPARE(settings.recentFolders().first(), "/folder14");
    QCOMPARE(settings.recentFolders().last(), "/folder5");

    // Test clearing the list
    settings.clearRecentFolders();
    QCOMPARE(settings.recentFolders().size(), 0);
}

void TestSettings::testBuildCommands()
{
    Settings settings;
    const QString projectPath = "/test/project";
    const QString buildCommand = "make";
    const QString runCommand = "./my_app";
    const QString cleanCommand = "make clean";

    // 1. Initially, commands should be empty
    QCOMPARE(settings.getBuildCommand(projectPath), "");
    QCOMPARE(settings.getRunCommand(projectPath), "");
    QCOMPARE(settings.getCleanCommand(projectPath), "");

    // 2. Set the commands
    settings.setBuildCommands(projectPath, buildCommand, runCommand, cleanCommand);

    // 3. Verify the commands are set correctly
    QCOMPARE(settings.getBuildCommand(projectPath), buildCommand);
    QCOMPARE(settings.getRunCommand(projectPath), runCommand);
    QCOMPARE(settings.getCleanCommand(projectPath), cleanCommand);

    // 4. Test persistence
    {
        Settings settings2;
        QCOMPARE(settings2.getBuildCommand(projectPath), buildCommand);
        QCOMPARE(settings2.getRunCommand(projectPath), runCommand);
        QCOMPARE(settings2.getCleanCommand(projectPath), cleanCommand);
    }

    // 5. Test with a different project path
    const QString otherProjectPath = "/another/project";
    QCOMPARE(settings.getBuildCommand(otherProjectPath), "");
    settings.setBuildCommands(otherProjectPath, "qmake", "./app", "rm *.o");
    QCOMPARE(settings.getBuildCommand(otherProjectPath), "qmake");

    // 6. Ensure the original project's settings are still intact
    QCOMPARE(settings.getBuildCommand(projectPath), buildCommand);
}
