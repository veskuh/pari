#include "test_editormanager.h"
#include "editor/editormanager.h"
#include <QSignalSpy>

void TestEditorManager::testOpenFile()
{
    EditorManager editorManager;
    QSignalSpy spy(&editorManager, &EditorManager::openDocumentsChanged);

    QCOMPARE(editorManager.openDocuments().size(), 0);
    QCOMPARE(editorManager.activeDocumentIndex(), -1);

    editorManager.openFile("test.txt");

    QCOMPARE(editorManager.openDocuments().size(), 1);
    QCOMPARE(editorManager.activeDocumentIndex(), 0);
    QCOMPARE(spy.count(), 1);

    Document *doc = qobject_cast<Document*>(editorManager.openDocuments().first());
    QVERIFY(doc != nullptr);
    QCOMPARE(doc->filePath(), "test.txt");
    QCOMPARE(doc->isDirty(), false);

    editorManager.openFile("test2.txt");
    QCOMPARE(editorManager.openDocuments().size(), 2);
    QCOMPARE(editorManager.activeDocumentIndex(), 1);
    QCOMPARE(spy.count(), 2);

    editorManager.openFile("test.txt");
    QCOMPARE(editorManager.openDocuments().size(), 2);
    QCOMPARE(editorManager.activeDocumentIndex(), 0);
    QCOMPARE(spy.count(), 2);
}

void TestEditorManager::testCloseFile()
{
    EditorManager editorManager;
    editorManager.openFile("test.txt");
    editorManager.openFile("test2.txt");

    QSignalSpy spy(&editorManager, &EditorManager::openDocumentsChanged);

    QCOMPARE(editorManager.openDocuments().size(), 2);
    QCOMPARE(editorManager.activeDocumentIndex(), 1);

    editorManager.closeFile(0);

    QCOMPARE(editorManager.openDocuments().size(), 1);
    QCOMPARE(editorManager.activeDocumentIndex(), 0);
    QCOMPARE(spy.count(), 1);

    Document *doc = qobject_cast<Document*>(editorManager.openDocuments().first());
    QVERIFY(doc != nullptr);
    QCOMPARE(doc->filePath(), "test2.txt");

    editorManager.closeFile(0);
    QCOMPARE(editorManager.openDocuments().size(), 0);
    QCOMPARE(editorManager.activeDocumentIndex(), -1);
    QCOMPARE(spy.count(), 2);
}

void TestEditorManager::testSaveFile()
{
    EditorManager editorManager;
    editorManager.openFile("test.txt");

    Document *doc = qobject_cast<Document*>(editorManager.openDocuments().first());
    doc->setDirty(true);

    QFile file("test.txt");
    file.open(QIODevice::WriteOnly | QIODevice::Text);
    file.close();

    editorManager.saveFile(0, "new content");

    QCOMPARE(doc->isDirty(), false);
    QCOMPARE(doc->content(), "new content");

    file.open(QIODevice::ReadOnly | QIODevice::Text);
    QCOMPARE(QString(file.readAll()), "new content");
    file.close();
}

void TestEditorManager::testDocumentContentChanged()
{
    EditorManager editorManager;
    editorManager.openFile("test.txt");

    Document *doc = qobject_cast<Document*>(editorManager.openDocuments().first());
    QCOMPARE(doc->isDirty(), false);

    editorManager.documentContentChanged(0, "new content");
    QCOMPARE(doc->isDirty(), true);

    editorManager.documentContentChanged(0, doc->content());
    QCOMPARE(doc->isDirty(), true);
}
