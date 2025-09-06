#include "gitmanager.h"

GitManager::GitManager(QObject *parent)
    : QObject{parent}
    , m_process(new QProcess(this))
{
    connect(m_process, &QProcess::finished, this, &GitManager::onProcessFinished);
}

GitManager::~GitManager()
{
    m_process->waitForFinished();
}

QString GitManager::currentBranch() const
{
    return m_currentBranch;
}

void GitManager::setWorkingDirectory(const QString &path)
{
    m_process->setWorkingDirectory(path);
}

void GitManager::refresh()
{
    m_process->start("git", {"branch", "--show-current"});
}

void GitManager::onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    if (exitCode == 0 && exitStatus == QProcess::NormalExit) {
        setCurrentBranch(QString::fromLocal8Bit(m_process->readAllStandardOutput()).trimmed());
    } else {
        setCurrentBranch("");
    }
}

void GitManager::setCurrentBranch(const QString &currentBranch)
{
    if (m_currentBranch == currentBranch)
        return;

    m_currentBranch = currentBranch;
    emit currentBranchChanged();
}
