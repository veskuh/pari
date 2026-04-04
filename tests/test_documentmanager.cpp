#include "test_documentmanager.h"
#include "../src/editor/documentmanager.h"
#include "../src/editor/textdocument.h"
#include <QtTest/QtTest>
#include <QUrl>
#include <QFile>
#include <QTextStream>

TestDocumentManager::TestDocumentManager(QObject *parent) : QObject(parent)
{
}

void TestDocumentManager::testOpenFile()
{
    DocumentManager docManager;
    QSignalSpy spy(&docManager, &DocumentManager::documentsChanged);

    docManager.openFile("test_file1.txt", true);

    QCOMPARE(spy.count(), 1);
    QCOMPARE(docManager.documents().size(), 1);
    QCOMPARE(static_cast<TextDocument*>(docManager.documents().first())->filePath(), QString("test_file1.txt"));
}

void TestDocumentManager::initTestCase()
{
    QFile file1("test_file1.txt");
    if (file1.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream out(&file1);
        out << "test content 1";
        file1.close();
    }

    QFile file2("test_file2.txt");
    if (file2.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream out(&file2);
        out << "test content 2";
        file2.close();
    }
}

void TestDocumentManager::cleanupTestCase()
{
    QFile::remove("test_file1.txt");
    QFile::remove("test_file2.txt");
}

void TestDocumentManager::testOpenFile_dirty()
{
    DocumentManager docManager;
    docManager.openFile("test_file1.txt", true);
    docManager.markDirty(0);
    docManager.openFile("test_file2.txt", true);
    QCOMPARE(docManager.documents().size(), 2);
}

void TestDocumentManager::testOpenFile_alreadyOpen()
{
    DocumentManager docManager;
    docManager.openFile("test_file1.txt", true);
    QCOMPARE(docManager.documents().size(), 1);
    
    // Open again, should not add a new document
    docManager.openFile("test_file1.txt", true);
    QCOMPARE(docManager.documents().size(), 1);
}

void TestDocumentManager::testIsDirty()
{
    DocumentManager docManager;
    QString filePath = "test_file1.txt";
    docManager.openFile(filePath, true);
    
    QVERIFY(!docManager.isDirty(filePath));
    
    docManager.markDirty(0);
    QVERIFY(docManager.isDirty(filePath));
    
    docManager.saveFile(0, "new content");
    QVERIFY(!docManager.isDirty(filePath));
}

void TestDocumentManager::testCloseFile()
{
    DocumentManager docManager;
    docManager.openFile("test_file1.txt", true);
    docManager.openFile("test_file2.txt", true);
    QCOMPARE(docManager.documents().size(), 2);
    
    docManager.closeFile(0);
    QCOMPARE(docManager.documents().size(), 1);
    QCOMPARE(static_cast<TextDocument*>(docManager.documents().first())->filePath(), QString("test_file2.txt"));
    
    docManager.closeFile(0);
    QCOMPARE(docManager.documents().size(), 0);
    QCOMPARE(docManager.currentIndex(), -1);
}

void TestDocumentManager::testSaveFileFailure()
{
    DocumentManager docManager;
    docManager.openFile("test_file1.txt", true);
    QVERIFY(docManager.saveFile(0, "success content"));
}

void TestDocumentManager::testSaveFile_invalidIndex()
{
    DocumentManager docManager;
    docManager.openFile("test_file1.txt", true);
    QVERIFY(!docManager.saveFile(1, "invalid index content"));
    QVERIFY(!docManager.saveFile(-1, "negative index content"));
}

void TestDocumentManager::testUpdatePath()
{
    DocumentManager docManager;
    docManager.openFile("test_file1.txt", true);
    
    QSignalSpy spy(&docManager, &DocumentManager::documentsChanged);
    docManager.updatePath("test_file1.txt", "new_name.txt");
    
    QCOMPARE(spy.count(), 1);
    QCOMPARE(static_cast<TextDocument*>(docManager.documents().first())->filePath(), QString("new_name.txt"));
}
