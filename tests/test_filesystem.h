#ifndef TEST_FILESYSTEM_H
#define TEST_FILESYSTEM_H

#include <QObject>

class TestFileSystem : public QObject
{
    Q_OBJECT

private slots:
    void testSaveFile();
    void testGetFileInfo();
};

#endif // TEST_FILESYSTEM_H
