#ifndef TEST_DOCUMENTMANAGER_H
#define TEST_DOCUMENTMANAGER_H

#include <QObject>

class TestDocumentManager : public QObject
{
    Q_OBJECT
public:
    explicit TestDocumentManager(QObject *parent = nullptr);

private slots:
    void initTestCase();
    void cleanupTestCase();
    void testOpenFile();
    void testOpenFile_dirty();
    void testOpenFile_alreadyOpen();
    void testIsDirty();
    void testCloseFile();
    void testSaveFileFailure();
    void testSaveFile_invalidIndex();
    void testUpdatePath();
};

#endif // TEST_DOCUMENTMANAGER_H
