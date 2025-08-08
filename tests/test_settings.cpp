#include <QTest>
#include <QSettings>
#include <QSignalSpy>
#include "app/settings.h"

class TestSettings : public QObject
{
    Q_OBJECT

private slots:
    void init();
    void cleanup();
    void testDefaults();
    void testSettersAndGetters();
    void testPersistence();
    void testSignals();
    void testAvailableModels();
};

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

QTEST_MAIN(TestSettings)
#include "test_settings.moc"
