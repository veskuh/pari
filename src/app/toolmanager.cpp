#include "toolmanager.h"
#include <QDebug>

ToolManager::ToolManager(QObject *parent)
    : QObject{parent}, m_branchProcess(new QProcess(this)), m_process(new QProcess(this))
{
    connect(m_branchProcess, &QProcess::finished, this, &ToolManager::onBranchProcessFinished);
    connect(m_process, &QProcess::finished, this, &ToolManager::onProcessFinished);
    connect(m_process, &QProcess::readyReadStandardOutput, this, &ToolManager::onReadyReadStandardOutput);
    connect(m_process, &QProcess::readyReadStandardError, this, &ToolManager::onReadyReadStandardError);
}

void ToolManager::runCommand(const QString &command, const QString &workingDirectory)
{
    if (m_branchProcess->state() == QProcess::NotRunning && m_process->state() == QProcess::NotRunning) {
        m_command = command;
        m_workingDirectory = workingDirectory;
        m_branchProcess->setWorkingDirectory(workingDirectory);
        m_branchProcess->startCommand("git branch --show-current");
    }
}

void ToolManager::onBranchProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
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

void ToolManager::onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    qDebug() << "Tool command" << m_command << "finished with exit code" << exitCode << "and exit status" << exitStatus;
}

void ToolManager::onReadyReadStandardOutput()
{
    emit outputReady(m_command, m_process->readAllStandardOutput(), m_branchName);
}

void ToolManager::onReadyReadStandardError()
{
    emit outputReady(m_command, m_process->readAllStandardError(), m_branchName);
}
