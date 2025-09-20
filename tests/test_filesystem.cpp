#include "test_filesystem.h"
#include <QtTest>
#include "filesystem.h"
#include <QTemporaryDir>
#include <QFile>

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

void TestFileSystem::testGetFileInfo()
{
    FileSystem fileSystem;
    QTemporaryDir tempDir;
    QString filePath = tempDir.path() + "/test.txt";
    QFile file(filePath);
    QVERIFY(file.open(QIODevice::WriteOnly | QIODevice::Text));
    QString content = "Hello, World!";
    file.write(content.toUtf8());
    file.close();

    QVariantMap fileInfo = fileSystem.getFileInfo(filePath);

    QCOMPARE(fileInfo["name"].toString(), "test.txt");
    QCOMPARE(fileInfo["path"].toString(), filePath);
    QCOMPARE(fileInfo["size"].toLongLong(), content.size());
}
