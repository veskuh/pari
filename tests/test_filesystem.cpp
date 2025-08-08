#include <QtTest>
#include "../src/app/filesystem.h"
#include <QTemporaryDir>
#include <QFile>

class TestFileSystem : public QObject
{
    Q_OBJECT

private slots:
    void testSaveFile();
};

void TestFileSystem::testSaveFile()
{
    FileSystem fileSystem;
    QTemporaryDir tempDir;
    QString filePath = tempDir.path() + "/test.txt";
    QString content = "Hello, World!";

    fileSystem.saveFile(filePath, content);

    QFile file(filePath);
    QVERIFY(file.exists());
    QVERIFY(file.open(QIODevice::ReadOnly | QIODevice::Text));
    QCOMPARE(QString(file.readAll()), content);
    file.close();
}

QTEST_APPLESS_MAIN(TestFileSystem)

#include "test_filesystem.moc"
