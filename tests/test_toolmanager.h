#ifndef TEST_TOOLMANAGER_H
#define TEST_TOOLMANAGER_H

#include <QObject>
#include <QtTest/QtTest>

class TestToolManager : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void testRunCommand();
    void testFormatDiffOutput();
    void testIndentQmlFile();
    void testRunCommandWithError();
};

#endif // TEST_TOOLMANAGER_H
