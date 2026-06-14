#include "test_gitblamemodel.h"
#include <QDateTime>

void TestGitBlameModel::initTestCase() {}

void TestGitBlameModel::testParsing() {
    GitBlameModel model;
    QString rawOutput = 
        "4a9e0123456789abcdef0123456789abcdef0123 1 1 1\n"
        "author Vesku\n"
        "author-mail <vesku.h@gmail.com>\n"
        "author-time 1713524400\n"
        "summary Initial commit\n"
        "\t#include <iostream>\n"
        "4a9e0123456789abcdef0123456789abcdef0123 2 2 1\n"
        "\tint main() {\n";
        
    model.parseRawOutput(rawOutput);
    
    QCOMPARE(model.rowCount(), 2);
    
    // Check first line
    QCOMPARE(model.data(model.index(0), GitBlameModel::HashRole).toString(), "4a9e0123");
    QCOMPARE(model.data(model.index(0), GitBlameModel::AuthorRole).toString(), "Vesku");
    QCOMPARE(model.data(model.index(0), GitBlameModel::EmailRole).toString(), "vesku.h@gmail.com");
    QCOMPARE(model.data(model.index(0), GitBlameModel::DateRole).toString(), "2024-04-19");
    QCOMPARE(model.data(model.index(0), GitBlameModel::ContentRole).toString(), "#include <iostream>");
    QCOMPARE(model.data(model.index(0), GitBlameModel::ShowMetadataRole).toBool(), true);
    
    // Check second line (same hash, metadata should be hidden)
    QCOMPARE(model.data(model.index(1), GitBlameModel::ContentRole).toString(), "int main() {");
    QCOMPARE(model.data(model.index(1), GitBlameModel::ShowMetadataRole).toBool(), false);
}

void TestGitBlameModel::testClear() {
    GitBlameModel model;
    model.parseRawOutput("4a9e0123456789abcdef0123456789abcdef0123 1 1 1\nauthor X\n\tcontent\n");
    QVERIFY(model.rowCount() > 0);
    model.clear();
    QCOMPARE(model.rowCount(), 0);
}

void TestGitBlameModel::cleanupTestCase() {}
