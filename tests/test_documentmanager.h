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
    void testOpenFile_data();
    void testOpenFile();
    void testOpenFile_dirty();
};

#endif // TEST_DOCUMENTMANAGER_H
