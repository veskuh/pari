#include "test_filesystem.h"
#include <QtTest>
#include "filesystem.h"
#include <QTemporaryDir>
#include <QFile>
#include <QSignalSpy>
#include <QAbstractItemModel>

namespace {
class MockSourceModel : public QAbstractItemModel
{
public:
    using QAbstractItemModel::QAbstractItemModel;

    void triggerLayoutChanged()
    {
        emit layoutChanged(QList<QPersistentModelIndex>(), QAbstractItemModel::VerticalSortHint);
    }

    QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const override
    {
        Q_UNUSED(parent);
        return createIndex(row, column);
    }
    QModelIndex parent(const QModelIndex &) const override { return QModelIndex(); }
    int rowCount(const QModelIndex &parent = QModelIndex()) const override { return parent.isValid() ? 0 : 1; }
    int columnCount(const QModelIndex &parent = QModelIndex()) const override
    {
        Q_UNUSED(parent);
        return 1;
    }
    QVariant data(const QModelIndex &, int) const override { return QVariant(); }
};
} // namespace

void TestFileSystem::initTestCase()
{
}

void TestFileSystem::cleanupTestCase()
{
}

void TestFileSystem::testSaveFile()
{
    FileSystem fileSystem;
    QTemporaryDir tempDir;
    QString filePath = tempDir.path() + "/test.txt";
    QString content = "Hello, World!";

    fileSystem.saveFile(filePath, content);

    QFile file(filePath);
    QVERIFY(file.exists());
    QVERIFY(file.open(QIODevice::ReadOnly | QIODevice::Text));
    QCOMPARE(QString(file.readAll()), content);
    file.close();
}

void TestFileSystem::testGetFileInfo()
{
    FileSystem fileSystem;
    QTemporaryDir tempDir;
    QString filePath = tempDir.path() + "/test.txt";
    QFile file(filePath);
    QVERIFY(file.open(QIODevice::WriteOnly | QIODevice::Text));
    QString content = "Hello, World!";
    file.write(content.toUtf8());
    file.close();

    QVariantMap fileInfo = fileSystem.getFileInfo(filePath);

    QCOMPARE(fileInfo["name"].toString(), "test.txt");
    QCOMPARE(fileInfo["path"].toString(), filePath);
    QCOMPARE(fileInfo["size"].toLongLong(), (long long)content.size());
}

void TestFileSystem::testRenameFile()
{
    FileSystem fileSystem;
    QTemporaryDir tempDir;
    QString oldPath = tempDir.path() + "/old.txt";
    QString newPath = tempDir.path() + "/new.txt";

    QFile file(oldPath);
    QVERIFY(file.open(QIODevice::WriteOnly));
    file.close();

    QVERIFY(fileSystem.renameFile(oldPath, newPath));

    QVERIFY(!QFile::exists(oldPath));
    QVERIFY(QFile::exists(newPath));
}

void TestFileSystem::testCreateNewFile()
{
    FileSystem fileSystem;
    QTemporaryDir tempDir;
    QString folderPath = tempDir.path();
    QString fileName = "new_file.txt";
    QString expectedPath = folderPath + "/" + fileName;

    QSignalSpy spy(&fileSystem, &FileSystem::fileContentReady);
    
    QVERIFY(fileSystem.createNewFile(folderPath, fileName));
    QVERIFY(QFile::exists(expectedPath));
    QCOMPARE(fileSystem.currentFilePath(), expectedPath);
    QCOMPARE(spy.count(), 1);
    QCOMPARE(spy.at(0).at(0).toString(), expectedPath);
    QCOMPARE(spy.at(0).at(1).toString(), QString(""));
}

void TestFileSystem::testLoadFileContent()
{
    FileSystem fileSystem;
    QTemporaryDir tempDir;
    QString filePath = tempDir.path() + "/test_load.txt";
    QString content = "Load this content";
    
    QFile file(filePath);
    QVERIFY(file.open(QIODevice::WriteOnly | QIODevice::Text));
    file.write(content.toUtf8());
    file.close();

    QSignalSpy spy(&fileSystem, &FileSystem::fileContentReady);
    fileSystem.loadFileContent(filePath);

    QCOMPARE(spy.count(), 1);
    QList<QVariant> arguments = spy.takeFirst();
    QCOMPARE(arguments.at(0).toString(), filePath);
    QCOMPARE(arguments.at(1).toString(), content);
}

void TestFileSystem::testSetRootPath()
{
    FileSystem fileSystem;
    QTemporaryDir tempDir;
    QString path = tempDir.path();
    
    // Test Git repo detection
    QDir dir(path);
    dir.mkdir(".git");
    
    QSignalSpy spy(&fileSystem, &FileSystem::projectOpened);
    QSignalSpy gitSpy(&fileSystem, &FileSystem::isGitRepositoryChanged);
    
    fileSystem.setRootPath(path);
    
    QCOMPARE(fileSystem.rootPath(), path);
    QVERIFY(fileSystem.isGitRepository());
    QCOMPARE(spy.count(), 1);
    QCOMPARE(gitSpy.count(), 1);
}

void TestFileSystem::testIsDirectory()
{
    FileSystem fileSystem;
    QTemporaryDir tempDir;
    QString path = tempDir.path();
    fileSystem.setRootPath(path);
    
    QDir dir(path);
    dir.mkdir("subdir");
    
    // QFileSystemModel is asynchronous, but for local paths it should be relatively fast.
    // However, isDirectory uses m_model->index(filePath) which might need some time.
    // Let's use a small wait if needed, but normally QFileSystemModel::setRootPath is enough.
    
    QVERIFY(fileSystem.isDirectory(path + "/subdir"));
}

void TestFileSystem::testFileExistsInProject()
{
    FileSystem fileSystem;
    QTemporaryDir tempDir;
    QString path = tempDir.path();
    fileSystem.setRootPath(path);
    
    QString filePath = path + "/in_project.txt";
    QFile file(filePath);
    file.open(QIODevice::WriteOnly);
    file.close();
    
    QVERIFY(fileSystem.fileExistsInProject("in_project.txt"));
    QVERIFY(fileSystem.fileExistsInProject(filePath));
    QVERIFY(!fileSystem.fileExistsInProject("non_existent.txt"));
}

void TestFileSystem::testGetAbsolutePath()
{
    FileSystem fileSystem;
    fileSystem.setRootPath("/tmp/pari");
    
    QCOMPARE(fileSystem.getAbsolutePath("file.txt"), QString("/tmp/pari/file.txt"));
    QCOMPARE(fileSystem.getAbsolutePath("/absolute/path.txt"), QString("/absolute/path.txt"));
}

void TestFileSystem::testProxyForwardsLayoutChanged()
{
    // Regression test: ProjectTreeProxyModel must NOT disconnect the source
    // model's layoutChanged signal. Suppressing it (as was done previously to
    // work around a QQuickTreeView bug) leaves QSortFilterProxyModel's internal
    // source->proxy index mapping stale after QFileSystemModel re-sorts on a
    // directory change, which makes the file tree show duplicate entries.
    ProjectTreeProxyModel proxy;
    MockSourceModel source;

    QSignalSpy spy(&proxy, &QAbstractItemModel::layoutChanged);

    proxy.setSourceModel(&source);
    QCOMPARE(spy.count(), 0);

    source.triggerLayoutChanged();

    QCOMPARE(spy.count(), 1);
}
