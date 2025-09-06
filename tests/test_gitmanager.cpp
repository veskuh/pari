#include "test_gitmanager.h"
#include "integrations/gitmanager.h"
#include <QSignalSpy>
#include <QTemporaryDir>
#include <QProcess>

void TestGitManager::testBranchName()
{
    QTemporaryDir tempDir;
    QProcess process;
    process.setWorkingDirectory(tempDir.path());

    // 1. Initialize a git repository
    process.start("git", {"init"});
    process.waitForFinished();

    // 2. Create a commit
    process.start("git", {"config", "user.email", "test@test.com"});
    process.waitForFinished();
    process.start("git", {"config", "user.name", "Test"});
    process.waitForFinished();
    process.start("git", {"commit", "--allow-empty", "-m", "Initial commit"});
    process.waitForFinished();

    // 3. Create a new branch
    process.start("git", {"checkout", "-b", "my-test-branch"});
    process.waitForFinished();

    // 4. Create a GitManager and check the branch name
    GitManager gitManager;
    gitManager.setWorkingDirectory(tempDir.path());
    gitManager.refresh();
    gitManager.refresh();
    QSignalSpy spy(&gitManager, &GitManager::currentBranchChanged);
    spy.wait(1000);

    QCOMPARE(gitManager.currentBranch(), "my-test-branch");
}
