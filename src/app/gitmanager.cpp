#include "gitmanager.h"
#include <QDebug>

GitManager::GitManager(QObject *parent)
    : QObject{parent}, m_branchProcess(new QProcess(this)), m_process(new QProcess(this))
{
    connect(m_branchProcess, &QProcess::finished, this, &GitManager::onBranchProcessFinished);
    connect(m_process, &QProcess::finished, this, &GitManager::onProcessFinished);
    connect(m_process, &QProcess::readyReadStandardOutput, this, &GitManager::onReadyReadStandardOutput);
    connect(m_process, &QProcess::readyReadStandardError, this, &GitManager::onReadyReadStandardError);
}

void GitManager::runCommand(const QString &command, const QString &workingDirectory)
{
    if (m_branchProcess->state() == QProcess::NotRunning && m_process->state() == QProcess::NotRunning) {
        m_command = command;
        m_workingDirectory = workingDirectory;
        m_branchProcess->setWorkingDirectory(workingDirectory);
        m_branchProcess->startCommand("git branch --show-current");
    }
}

void GitManager::onBranchProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    if (exitCode == 0 && exitStatus == QProcess::NormalExit) {
        m_branchName = m_branchProcess->readAllStandardOutput().trimmed();
        m_process->setWorkingDirectory(m_workingDirectory);
        m_process->startCommand(m_command);
    } else {
        qDebug() << "Failed to get branch name";
        m_branchName = "unknown";
        m_process->setWorkingDirectory(m_workingDirectory);
        m_process->startCommand(m_command);
    }
}

void GitManager::onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    qDebug() << "Git command" << m_command << "finished with exit code" << exitCode << "and exit status" << exitStatus;
}

void GitManager::onReadyReadStandardOutput()
{
    emit outputReady(m_command, m_process->readAllStandardOutput(), m_branchName);
}

void GitManager::onReadyReadStandardError()
{
    emit outputReady(m_command, m_process->readAllStandardError(), m_branchName);
}
