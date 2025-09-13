#include "test_documentmanager.h"
#include "../src/editor/documentmanager.h"
#include "../src/editor/textdocument.h"
#include <QtTest/QtTest>
#include <QUrl>

TestDocumentManager::TestDocumentManager(QObject *parent) : QObject(parent)
{
}

void TestDocumentManager::testOpenFile_data()
{
    QTest::addColumn<QString>("filePath");
    QTest::newRow("file1") << "test_file1.txt";
}

void TestDocumentManager::testOpenFile()
{
    QFETCH(QString, filePath);

    DocumentManager docManager;
    QSignalSpy spy(&docManager, &DocumentManager::documentsChanged);

    docManager.openFile(filePath, "test content");

    QCOMPARE(spy.count(), 1);
    QCOMPARE(docManager.documents().size(), 1);
    QCOMPARE(static_cast<TextDocument*>(docManager.documents().first())->filePath(), filePath);
    QCOMPARE(static_cast<TextDocument*>(docManager.documents().first())->text(), "test content");
}

void TestDocumentManager::testOpenFile_dirty()
{
    DocumentManager docManager;
    docManager.openFile("test_file1.txt", "test content 1");
    docManager.markDirty(0);
    docManager.openFile("test_file2.txt", "test content 2");
    QCOMPARE(docManager.documents().size(), 2);
}
