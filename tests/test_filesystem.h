#ifndef TEST_FILESYSTEM_H
#define TEST_FILESYSTEM_H

#include <QObject>

class TestFileSystem : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void testSaveFile();
    void testGetFileInfo();
    void testRenameFile();
    void testLoadFileContent();
    void testSetRootPath();
    void testIsDirectory();
    void testFileExistsInProject();
    void testGetAbsolutePath();
};

#endif // TEST_FILESYSTEM_H
