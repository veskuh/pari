#include "buildmanager.h"
#include <QProcessEnvironment>
#include <QDebug>

BuildManager::BuildManager(QObject *parent)
    : QObject{parent}, m_process(new QProcess(this))
{
    connect(m_process, &QProcess::finished, this, &BuildManager::onProcessFinished);
    connect(m_process, &QProcess::readyReadStandardOutput, this, &BuildManager::onReadyReadStandardOutput);
    connect(m_process, &QProcess::readyReadStandardError, this, &BuildManager::onReadyReadStandardError);
    connect(m_process, &QProcess::errorOccurred, this, &BuildManager::onErrorOccurred);
}

void BuildManager::executeCommand(const QString &command, const QString &workingDirectory)
{
    if (m_process->state() == QProcess::NotRunning && !command.isEmpty()) {
        m_currentCommand = command;
        m_process->setWorkingDirectory(workingDirectory);
        m_process->startCommand(command);
    }
}

void BuildManager::onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    qDebug() << "Process finished with exit code:" << exitCode << "and exit status:" << exitStatus;
    Q_UNUSED(exitCode);
    Q_UNUSED(exitStatus);
    emit finished();
}

void BuildManager::onErrorOccurred(QProcess::ProcessError error)
{
    qDebug() << "Process error occurred:" << error;
    if (error == QProcess::FailedToStart) {
        QString exeName = "";
        QStringList parts = m_currentCommand.split(' ');
        if (!parts.isEmpty()) {
            exeName = parts.first();
        }
        
        QString errorDetail = m_process->errorString();
        QString errMsg = QString("Failed to start process: %1\n"
                                 "Executable: '%2'\n\n"
                                 "Please ensure that the executable exists, has execute permissions (the 'x' bit), and is present in your system PATH.\n"
                                 "Current PATH: %3")
                                 .arg(errorDetail, exeName, QProcessEnvironment::systemEnvironment().value("PATH"));
        emit errorReady(errMsg);
        emit finished();
    }
}

void BuildManager::onReadyReadStandardOutput()
{
    emit outputReady(m_process->readAllStandardOutput());
}

void BuildManager::onReadyReadStandardError()
{
    emit errorReady(m_process->readAllStandardError());
}
