#include "toolmanager.h"
#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <QTemporaryFile>
#include <QCoreApplication>
#include <QDir>

ToolManager::ToolManager(QObject *parent)
    : QObject{parent}, m_branchProcess(new QProcess(this)), m_process(new QProcess(this)), m_qmlFormatProcess(new QProcess(this)), m_tempQmlFile(nullptr)
{
    connect(m_branchProcess, &QProcess::finished, this, &ToolManager::onBranchProcessFinished);
    connect(m_process, &QProcess::finished, this, &ToolManager::onProcessFinished);
    connect(m_process, &QProcess::readyReadStandardOutput, this, &ToolManager::onReadyReadStandardOutput);
    connect(m_process, &QProcess::readyReadStandardError, this, &ToolManager::onReadyReadStandardError);
    connect(m_qmlFormatProcess, &QProcess::finished, this, &ToolManager::onQmlFormatProcessFinished);
}

void ToolManager::runCommand(const QString &command, const QString &workingDirectory)
{
    if (m_branchProcess->state() == QProcess::NotRunning && m_process->state() == QProcess::NotRunning) {
        m_command = command;
        m_workingDirectory = workingDirectory;
        m_outputBuffer.clear();
        m_errorBuffer.clear();
        m_branchProcess->setWorkingDirectory(workingDirectory);
        m_branchProcess->start("/bin/sh", QStringList() << "-c" << "git branch --show-current");
    }
}

void ToolManager::indentQmlFile(const QString &filePath, const QString &content)
{
    m_originalQmlContent = content;

    if (m_tempQmlFile) {
        m_tempQmlFile->deleteLater(); // Delete any previous temporary file
    }
    m_tempQmlFile = new QTemporaryFile(QDir::temp().filePath("tempfile.XXXXXX.qml"));

    if (m_tempQmlFile->open()) {
        QTextStream out(m_tempQmlFile);
        out << content;
        out.flush();
        m_tempQmlFile->close();

        m_qmlFormatProcess->start("qmlformat", QStringList() << m_tempQmlFile->fileName());
    } else {
        qDebug() << "Failed to create temporary file for QML formatting.";
        delete m_tempQmlFile;
        m_tempQmlFile = nullptr;
    }
}

void ToolManager::onBranchProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    if (exitCode == 0 && exitStatus == QProcess::NormalExit) {
        m_branchName = m_branchProcess->readAllStandardOutput().trimmed();
        m_process->setWorkingDirectory(m_workingDirectory);
        m_process->start("/bin/sh", QStringList() << "-c" << m_command);
    } else {
        qDebug() << "Failed to get branch name";
        m_branchName = "unknown";
        m_process->setWorkingDirectory(m_workingDirectory);
        m_process->start("/bin/sh", QStringList() << "-c" << m_command);
    }
}

void ToolManager::onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    // Read any remaining data
    m_outputBuffer.append(m_process->readAllStandardOutput());
    m_errorBuffer.append(m_process->readAllStandardError());

    qDebug() << "ToolManager: Process finished. Command:" << m_command << "Output size:" << m_outputBuffer.size();

    if (m_command.startsWith("git log")) {
        emit gitLogReady(m_outputBuffer);
    } else {
        if (!m_errorBuffer.isEmpty()) {
            emit outputReady(m_command, m_errorBuffer, m_branchName);
        } else {
            emit outputReady(m_command, formatDiffOutput(m_outputBuffer), m_branchName);
        }
    }
    m_outputBuffer.clear();
    m_errorBuffer.clear();
    qDebug() << "Tool command" << m_command << "finished with exit code" << exitCode << "and exit status" << exitStatus;
}

void ToolManager::onReadyReadStandardOutput()
{
    m_outputBuffer.append(m_process->readAllStandardOutput());
}

void ToolManager::onReadyReadStandardError()
{
    m_errorBuffer.append(m_process->readAllStandardError());
}

void ToolManager::onQmlFormatProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    if (m_tempQmlFile) {
        if (exitCode == 0 && exitStatus == QProcess::NormalExit) {
            emit qmlFileIndented(m_qmlFormatProcess->readAllStandardOutput());
        } else {
            qDebug() << "qmlformat failed with exit code" << exitCode << "and exit status" << exitStatus;
            qDebug() << m_qmlFormatProcess->readAllStandardError();
            emit qmlFileIndented(m_originalQmlContent); // Emit original content on error
        }
        m_tempQmlFile->deleteLater(); // Schedule for deletion
        m_tempQmlFile = nullptr;
    } else {
        qDebug() << "Temporary QML file object is null.";
        emit qmlFileIndented(m_originalQmlContent); // Emit original content if temp file is null
    }
}

QString ToolManager::formatDiffOutput(const QString &output) const
{
    if (output.isEmpty()) return QString();

    QString escaped = output;
    escaped.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    
    QStringList lines = escaped.split('\n');
    QString formattedOutput = "<div style=\"white-space: pre; font-family: monospace;\">";
    
    for (const QString &line : lines) {
        if (line.startsWith('+')) {
            formattedOutput += "<font color=\"#228b22\">" + line + "</font><br>";
        } else if (line.startsWith('-')) {
            formattedOutput += "<font color=\"#cc0000\">" + line + "</font><br>";
        } else if (line.startsWith('@')) {
            formattedOutput += "<font color=\"#0000ff\">" + line + "</font><br>";
        } else {
            formattedOutput += line + "<br>";
        }
    }
    
    formattedOutput += "</div>";
    return formattedOutput;
}
