#ifndef TEST_DIFFUTILS_H
#define TEST_DIFFUTILS_H

#include <QObject>

class TestDiffUtils : public QObject
{
    Q_OBJECT

private slots:
    void testNoChange();
    void testSimpleAddition();
    void testSimpleDeletion();
    void testModification();
    void testEmptyInputs();
    void testAllAdded();
    void testAllRemoved();
};

#endif // TEST_DIFFUTILS_H
