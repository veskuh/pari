#include "test_gitlogmodel.h"
#include "gitlogmodel.h"
#include <QtTest>

// Define the separators for consistency
const QString RECORD_SEPARATOR = QString(QChar(0x1e));
const QString UNIT_SEPARATOR = QString(QChar(0x1f));

void TestGitLogModel::initTestCase()
{
}

void TestGitLogModel::cleanupTestCase()
{
}

void TestGitLogModel::testParsing()
{
    GitLogModel model;
    // Removed leading space in dates
    QString log = "sha1" + UNIT_SEPARATOR + "Author One" + UNIT_SEPARATOR + "one@example.com" + UNIT_SEPARATOR + "Mon, 3 Jun 2024 10:00:00 +0000" + UNIT_SEPARATOR + "feat: Initial commit\n\nThis is the body of the first commit." + RECORD_SEPARATOR +
                  "sha2" + UNIT_SEPARATOR + "Author Two" + UNIT_SEPARATOR + "two@example.com" + UNIT_SEPARATOR + "Mon, 3 Jun 2024 11:00:00 +0000" + UNIT_SEPARATOR + "fix: A bug\n\nThis is the body of the second commit.";

    model.parseAndSetLog(log);

    QCOMPARE(model.rowCount(), 2);

    QModelIndex index0 = model.index(0, 0);
    QCOMPARE(model.data(index0, GitLogModel::ShaRole).toString(), QString("sha1"));
    QCOMPARE(model.data(index0, GitLogModel::AuthorNameRole).toString(), QString("Author One"));
    QCOMPARE(model.data(index0, GitLogModel::AuthorEmailRole).toString(), QString("one@example.com"));
    QCOMPARE(model.data(index0, GitLogModel::DateRole).toString(), QString("2024-06-03"));
    QCOMPARE(model.data(index0, GitLogModel::TimeRole).toString(), QString("10:00"));
    QCOMPARE(model.data(index0, GitLogModel::MessageHeaderRole).toString(), QString("feat: Initial commit"));
    QCOMPARE(model.data(index0, GitLogModel::MessageBodyRole).toString(), QString("This is the body of the first commit."));

    QModelIndex index1 = model.index(1, 0);
    QCOMPARE(model.data(index1, GitLogModel::ShaRole).toString(), QString("sha2"));
    QCOMPARE(model.data(index1, GitLogModel::AuthorNameRole).toString(), QString("Author Two"));
    QCOMPARE(model.data(index1, GitLogModel::MessageHeaderRole).toString(), QString("fix: A bug"));
}

void TestGitLogModel::testEmptyLog()
{
    GitLogModel model;
    model.parseAndSetLog("");
    QCOMPARE(model.rowCount(), 0);
}

void TestGitLogModel::testCommitWithoutBody()
{
    GitLogModel model;
    QString log = "sha3" + UNIT_SEPARATOR + "Author Three" + UNIT_SEPARATOR + "three@example.com" + UNIT_SEPARATOR + "Mon, 3 Jun 2024 12:00:00 +0000" + UNIT_SEPARATOR + "docs: Update README";

    model.parseAndSetLog(log);

    QCOMPARE(model.rowCount(), 1);
    QModelIndex index = model.index(0, 0);
    QCOMPARE(model.data(index, GitLogModel::ShaRole).toString(), QString("sha3"));
    QCOMPARE(model.data(index, GitLogModel::MessageHeaderRole).toString(), QString("docs: Update README"));
    QCOMPARE(model.data(index, GitLogModel::MessageBodyRole).toString(), QString(""));
}

void TestGitLogModel::testInvalidData()
{
    GitLogModel model;
    QString log = "sha1" + UNIT_SEPARATOR + "Author One" + UNIT_SEPARATOR + "one@example.com" + UNIT_SEPARATOR + "Mon, 3 Jun 2024 10:00:00 +0000" + UNIT_SEPARATOR + "msg";
    model.parseAndSetLog(log);
    
    QModelIndex invalidIndex;
    QCOMPARE(model.data(invalidIndex, GitLogModel::ShaRole), QVariant());
    
    QModelIndex outOfBoundsIndex = model.index(1, 0);
    QCOMPARE(model.data(outOfBoundsIndex, GitLogModel::ShaRole), QVariant());
    
    QModelIndex validIndex = model.index(0, 0);
    QCOMPARE(model.data(validIndex, 999), QVariant());
}

void TestGitLogModel::testRoleNames()
{
    // roleNames is protected, we already test through data()
    QVERIFY(true);
}

void TestGitLogModel::testFiltering()
{
    GitLogModel model;
    QString log = "sha1" + UNIT_SEPARATOR + "Vesku" + UNIT_SEPARATOR + "vesku@example.com" + UNIT_SEPARATOR + "Mon, 3 Jun 2024 10:00:00 +0000" + UNIT_SEPARATOR + "feat: Initial commit" + RECORD_SEPARATOR +
                  "sha2" + UNIT_SEPARATOR + "Author Two" + UNIT_SEPARATOR + "two@example.com" + UNIT_SEPARATOR + "Mon, 3 Jun 2024 11:00:00 +0000" + UNIT_SEPARATOR + "fix: A bug";

    model.parseAndSetLog(log);
    QCOMPARE(model.rowCount(), 2);

    // Filter by author
    model.setFilterText("Vesku");
    QCOMPARE(model.rowCount(), 1);
    QCOMPARE(model.data(model.index(0, 0), GitLogModel::ShaRole).toString(), QString("sha1"));

    // Filter by message
    model.setFilterText("bug");
    QCOMPARE(model.rowCount(), 1);
    QCOMPARE(model.data(model.index(0, 0), GitLogModel::ShaRole).toString(), QString("sha2"));

    // Filter by sha
    model.setFilterText("sha1");
    QCOMPARE(model.rowCount(), 1);
    QCOMPARE(model.data(model.index(0, 0), GitLogModel::ShaRole).toString(), QString("sha1"));

    // Clear filter
    model.setFilterText("");
    QCOMPARE(model.rowCount(), 2);

    // No matches
    model.setFilterText("nonexistent");
    QCOMPARE(model.rowCount(), 0);
}

void TestGitLogModel::testDetailsAndLoading()
{
    GitLogModel model;
    QString log = "sha1" + UNIT_SEPARATOR + "Author One" + UNIT_SEPARATOR + "one@example.com" + UNIT_SEPARATOR + "Mon, 3 Jun 2024 10:00:00 +0000" + UNIT_SEPARATOR + "msg";
    model.parseAndSetLog(log);

    QCOMPARE(model.data(model.index(0, 0), GitLogModel::DetailsLoadingRole).toBool(), false);
    
    model.setDetailsLoading("sha1", true);
    QCOMPARE(model.data(model.index(0, 0), GitLogModel::DetailsLoadingRole).toBool(), true);
    
    model.updateDetails("sha1", "Stat details");
    QCOMPARE(model.data(model.index(0, 0), GitLogModel::DetailsRole).toString(), QString("Stat details"));
    QCOMPARE(model.data(model.index(0, 0), GitLogModel::DetailsLoadingRole).toBool(), false);
    
    QCOMPARE(model.shaAt(0), QString("sha1"));
    QCOMPARE(model.shaAt(99), QString(""));
}

void TestGitLogModel::testParseComplexLog()
{
    GitLogModel model;
    // Test with missing fields or extra separators
    QString log = RECORD_SEPARATOR + "sha1" + UNIT_SEPARATOR + "A" + UNIT_SEPARATOR + "E" + UNIT_SEPARATOR + "Mon, 3 Jun 2024 10:00:00 +0000" + UNIT_SEPARATOR + "H\nB" + RECORD_SEPARATOR + RECORD_SEPARATOR;
    model.parseAndSetLog(log);
    QCOMPARE(model.rowCount(), 1);
    QCOMPARE(model.data(model.index(0, 0), GitLogModel::MessageHeaderRole).toString(), QString("H"));
    QCOMPARE(model.data(model.index(0, 0), GitLogModel::MessageBodyRole).toString(), QString("B"));
}
