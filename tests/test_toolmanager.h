#ifndef TEST_TOOLMANAGER_H
#define TEST_TOOLMANAGER_H

#include <QObject>
#include <QtTest/QtTest>

class TestToolManager : public QObject
{
    Q_OBJECT

private slots:
    void testRunCommand();
};

#endif // TEST_TOOLMANAGER_H
