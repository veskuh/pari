#ifndef TEST_SETTINGS_H
#define TEST_SETTINGS_H

#include <QObject>

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

#endif // TEST_SETTINGS_H
