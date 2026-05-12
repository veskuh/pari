#include "test_projectsearchmodel.h"
#include <QFile>
#include <QTextStream>
#include <QSignalSpy>

void TestProjectSearchModel::initTestCase()
{
    QVERIFY(m_tempDir.isValid());
    m_testPath = m_tempDir.path();

    // Create some test files
    auto createFile = [](const QString &path, const QString &content) {
        QFile file(path);
        if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            QTextStream out(&file);
            out << content;
            file.close();
        }
    };

    createFile(m_testPath + "/main.cpp", "int main() { return 0; }\n// test comment");
    createFile(m_testPath + "/utils.h", "void helper();");
    createFile(m_testPath + "/readme.md", "# Project Pari\nGlobal search test.");
    createFile(m_testPath + "/unsupported.xyz", "searchable but ignored by default");
}

void TestProjectSearchModel::cleanupTestCase()
{
}

void TestProjectSearchModel::testBasicSearch()
{
    ProjectSearchModel model;
    QSignalSpy spy(&model, &ProjectSearchModel::searchFinished);

    model.search(m_testPath, "main", true, false, "");
    QVERIFY(spy.wait(2000));

    // Should find: 
    // 1. main.cpp filename (lineNumber 0)
    // 2. "int main()" in main.cpp
    bool foundContent = false;
    bool foundFilename = false;

    for (int i = 0; i < model.rowCount(); ++i) {
        QString text = model.data(model.index(i), ProjectSearchModel::LineTextRole).toString();
        int line = model.data(model.index(i), ProjectSearchModel::LineNumberRole).toInt();
        if (line == 0 && text == "main.cpp") foundFilename = true;
        if (line == 1 && text.contains("int main()")) foundContent = true;
    }

    QVERIFY(foundFilename);
    QVERIFY(foundContent);
}

void TestProjectSearchModel::testFilenameMatch()
{
    ProjectSearchModel model;
    QSignalSpy spy(&model, &ProjectSearchModel::searchFinished);

    model.search(m_testPath, "utils", true, false, "");
    QVERIFY(spy.wait(2000));

    bool found = false;
    for (int i = 0; i < model.rowCount(); ++i) {
        if (model.data(model.index(i), ProjectSearchModel::LineNumberRole).toInt() == 0 &&
            model.data(model.index(i), ProjectSearchModel::LineTextRole).toString() == "utils.h") {
            found = true;
            break;
        }
    }
    QVERIFY(found);
}

void TestProjectSearchModel::testRegexSearch()
{
    ProjectSearchModel model;
    QSignalSpy spy(&model, &ProjectSearchModel::searchFinished);

    model.search(m_testPath, "ret.*0", true, true, "");
    QVERIFY(spy.wait(2000));

    bool found = false;
    for (int i = 0; i < model.rowCount(); ++i) {
        if (model.data(model.index(i), ProjectSearchModel::LineTextRole).toString().contains("return 0")) {
            found = true;
            break;
        }
    }
    QVERIFY(found);
}

void TestProjectSearchModel::testCaseSensitivity()
{
    ProjectSearchModel model;
    QSignalSpy spy(&model, &ProjectSearchModel::searchFinished);

    // Case insensitive
    model.search(m_testPath, "MAIN", false, false, "");
    QVERIFY(spy.wait(2000));
    QVERIFY(model.rowCount() > 0);

    // Case sensitive
    model.clear();
    QSignalSpy spy2(&model, &ProjectSearchModel::searchFinished);
    model.search(m_testPath, "MAIN", true, false, "");
    QVERIFY(spy2.wait(2000));
    QCOMPARE(model.rowCount(), 0);
}

void TestProjectSearchModel::testExtensionFiltering()
{
    ProjectSearchModel model;
    QSignalSpy spy(&model, &ProjectSearchModel::searchFinished);

    // By default .xyz is not searched
    model.search(m_testPath, "unsupported", true, false, "");
    QVERIFY(spy.wait(2000));
    QCOMPARE(model.rowCount(), 0);

    // Manual scope filter
    model.clear();
    QSignalSpy spy2(&model, &ProjectSearchModel::searchFinished);
    model.search(m_testPath, "unsupported", true, false, "xyz");
    QVERIFY(spy2.wait(2000));
    
    bool foundFilename = false;
    QStringList foundItems;
    for (int i = 0; i < model.rowCount(); ++i) {
        QString text = model.data(model.index(i), ProjectSearchModel::LineTextRole).toString();
        int line = model.data(model.index(i), ProjectSearchModel::LineNumberRole).toInt();
        foundItems << QString("Line %1: %2").arg(line).arg(text);
        if (line == 0 && text == "unsupported.xyz") {
            foundFilename = true;
            break;
        }
    }
    if (!foundFilename) {
        qDebug() << "Search failed to find unsupported.xyz. Found instead:" << foundItems;
    }
    QVERIFY(foundFilename);
}

void TestProjectSearchModel::testReplaceAll()
{
    ProjectSearchModel model;
    QSignalSpy spy(&model, &ProjectSearchModel::searchFinished);

    model.search(m_testPath, "search test", true, false, "md");
    QVERIFY(spy.wait(2000));
    QCOMPARE(model.rowCount(), 1); // Only content matches

    model.replaceAll("Final version");
    
    // Verify file content changed
    QFile file(m_testPath + "/readme.md");
    QVERIFY(file.open(QIODevice::ReadOnly | QIODevice::Text));
    QString content = file.readAll();
    QVERIFY(content.contains("Final version"));
}

void TestProjectSearchModel::testCancellation()
{
    ProjectSearchModel model;
    model.search(m_testPath, "test", true, false, "");
    model.cancel();
    // Wait a bit to ensure no results pop in after cancellation
    QTest::qWait(100);
    QCOMPARE(model.isSearching(), false);
}
