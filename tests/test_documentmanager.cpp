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

void TestDocumentManager::testAutoreloadNonDirty()
{
    DocumentManager docManager;
    QString filePath = "test_file1.txt";
    docManager.openFile(filePath, true);

    QSignalSpy spy(&docManager, &DocumentManager::fileContentReloaded);

    // Simulate external edit by writing to the file
    QFile file(filePath);
    QVERIFY(file.open(QIODevice::WriteOnly | QIODevice::Text));
    QTextStream out(&file);
    out << "externally edited content";
    file.close();

    // Advance file modification time explicitly to make sure it triggers
    QDateTime newTime = QDateTime::currentDateTime().addSecs(10);
    QVERIFY(file.open(QIODevice::ReadWrite));
    QVERIFY(file.setFileTime(newTime, QFileDevice::FileModificationTime));
    file.close();

    // Wait for the filesystem watcher event + debounced reload
    QVERIFY(spy.wait(1000));

    // Verify it automatically reloaded
    QCOMPARE(docManager.documents().size(), 1);
    TextDocument *doc = static_cast<TextDocument*>(docManager.documents().first());
    QCOMPARE(doc->text(), QString("externally edited content"));
    QVERIFY(!doc->isDirty());
    QCOMPARE(spy.count(), 1);
}

void TestDocumentManager::testNoAutoreloadDirty()
{
    DocumentManager docManager;
    QString filePath = "test_file1.txt";
    docManager.openFile(filePath, true);

    // Mark dirty and modify text locally
    docManager.markDirty(0);
    TextDocument *doc = static_cast<TextDocument*>(docManager.documents().first());
    doc->setText("locally modified content");

    QSignalSpy spyReloaded(&docManager, &DocumentManager::fileContentReloaded);
    QSignalSpy spyModifiedExternally(&docManager, &DocumentManager::fileModifiedExternally);

    // Simulate external edit by writing to the file
    QFile file(filePath);
    QVERIFY(file.open(QIODevice::WriteOnly | QIODevice::Text));
    QTextStream out(&file);
    out << "externally edited dirty content";
    file.close();

    QDateTime newTime = QDateTime::currentDateTime().addSecs(20);
    QVERIFY(file.open(QIODevice::ReadWrite));
    QVERIFY(file.setFileTime(newTime, QFileDevice::FileModificationTime));
    file.close();

    // Wait for the filesystem watcher event + debounced reload-decision
    QVERIFY(spyModifiedExternally.wait(1000));

    // Verify it did NOT reload and did NOT lose local changes
    QCOMPARE(doc->text(), QString("locally modified content"));
    QVERIFY(doc->isDirty());
    QCOMPARE(spyReloaded.count(), 0);

    // Since it was the active file (currentIndex = 0), it should emit fileModifiedExternally
    QCOMPARE(spyModifiedExternally.count(), 1);
    QCOMPARE(spyModifiedExternally.first().at(0).toString(), filePath);
}

void TestDocumentManager::testSaveFileIgnoresSelfSave()
{
    DocumentManager docManager;
    QString filePath = "test_file1.txt";
    docManager.openFile(filePath, true);

    QSignalSpy spyReloaded(&docManager, &DocumentManager::fileContentReloaded);
    QSignalSpy spyModifiedExternally(&docManager, &DocumentManager::fileModifiedExternally);

    // Save locally
    QVERIFY(docManager.saveFile(0, "saved by pari"));

    // Wait long enough for any watcher + debounce events to have been processed
    QTest::qWait(500);

    // Verify no signal was emitted
    QCOMPARE(spyReloaded.count(), 0);
    QCOMPARE(spyModifiedExternally.count(), 0);

    // File should contain the saved text
    QFile file(filePath);
    QVERIFY(file.open(QIODevice::ReadOnly | QIODevice::Text));
    QTextStream in(&file);
    QCOMPARE(in.readAll(), QString("saved by pari"));
}

