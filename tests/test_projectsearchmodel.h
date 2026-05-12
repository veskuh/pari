#ifndef TEST_PROJECTSEARCHMODEL_H
#define TEST_PROJECTSEARCHMODEL_H

#include <QtTest>
#include "projectsearchmodel.h"

class TestProjectSearchModel : public QObject
{
    Q_OBJECT
private slots:
    void initTestCase();
    void testBasicSearch();
    void testFilenameMatch();
    void testRegexSearch();
    void testCaseSensitivity();
    void testExtensionFiltering();
    void testReplaceAll();
    void testCancellation();
    void cleanupTestCase();

private:
    QTemporaryDir m_tempDir;
    QString m_testPath;
};

#endif // TEST_PROJECTSEARCHMODEL_H
