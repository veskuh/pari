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

    QFile file(filePath);
    file.open(QIODevice::WriteOnly | QIODevice::Text);
    file.write("test content");
    file.close();

    docManager.openFile(QUrl::fromLocalFile(filePath));

    QCOMPARE(spy.count(), 1);
    QCOMPARE(docManager.documents().size(), 1);
    QCOMPARE(static_cast<TextDocument*>(docManager.documents().first())->filePath(), filePath);
    QCOMPARE(static_cast<TextDocument*>(docManager.documents().first())->text(), "test content");
}

void TestDocumentManager::testOpenFile_dirty()
{
    DocumentManager docManager;
    docManager.openFile(QUrl::fromLocalFile("test_file1.txt"));
    docManager.markDirty(0);
    docManager.openFile(QUrl::fromLocalFile("test_file2.txt"));
    QCOMPARE(docManager.documents().size(), 2);
}
