#ifndef TEST_EDITORMANAGER_H
#define TEST_EDITORMANAGER_H

#include <QObject>
#include <QTest>

class TestEditorManager : public QObject
{
    Q_OBJECT

private slots:
    void testOpenFile();
    void testCloseFile();
    void testSaveFile();
    void testDocumentContentChanged();
};

#endif // TEST_EDITORMANAGER_H
