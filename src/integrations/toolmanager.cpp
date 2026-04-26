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
    m_command = command;
    m_workingDirectory = workingDirectory;
    m_outputBuffer.clear();
    m_errorBuffer.clear();

    if (m_process->state() != QProcess::NotRunning) {
        m_process->kill();
    }

    m_process->setWorkingDirectory(workingDirectory);
    m_process->start("sh", QStringList() << "-c" << command);
}

void ToolManager::getBranchName(const QString &workingDirectory)
{
    if (m_branchProcess->state() != QProcess::NotRunning) {
        m_branchProcess->kill();
    }
    m_branchProcess->setWorkingDirectory(workingDirectory);
    m_branchProcess->start("git", QStringList() << "rev-parse" << "--abbrev-ref" << "HEAD");
}

void ToolManager::indentQmlFile(const QString &filePath, const QString &content)
{
    Q_UNUSED(filePath);
    m_originalQmlContent = content;

    if (m_tempQmlFile) {
        m_tempQmlFile->deleteLater();
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

void ToolManager::onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    Q_UNUSED(exitCode);
    Q_UNUSED(exitStatus);

    qDebug() << "ToolManager: Process finished. Command:" << m_command << "Output size:" << m_outputBuffer.size();

    if (m_command.startsWith("git log")) {
        emit gitLogReady(m_outputBuffer);
    } else if (m_command.contains("git show --stat")) {
        QString sha = m_command.split(" ").last();
        emit commitDetailsReady(sha, m_outputBuffer);
    } else if (m_command.contains("git diff") || m_command.contains("git show")) {
        emit gitDiffReady(m_outputBuffer);
        emit outputReady(m_command, formatDiffOutput(m_outputBuffer), m_branchName);
    } else if (m_command.contains("git blame")) {
        emit outputReady(m_command, m_outputBuffer, m_branchName);
    } else {
        emit outputReady(m_command, m_outputBuffer.isEmpty() ? m_errorBuffer : m_outputBuffer, m_branchName);
    }
}

void ToolManager::onBranchProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    if (exitCode == 0 && exitStatus == QProcess::NormalExit) {
        m_branchName = m_branchProcess->readAllStandardOutput().trimmed();
    } else {
        m_branchName = "";
    }
}

void ToolManager::onQmlFormatProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    if (m_tempQmlFile) {
        if (exitCode == 0 && exitStatus == QProcess::NormalExit) {
            emit qmlFileIndented(m_qmlFormatProcess->readAllStandardOutput());
        } else {
            emit qmlFileIndented(m_originalQmlContent);
        }
        m_tempQmlFile->deleteLater();
        m_tempQmlFile = nullptr;
    }
}

void ToolManager::onReadyReadStandardOutput()
{
    m_outputBuffer += m_process->readAllStandardOutput();
}

void ToolManager::onReadyReadStandardError()
{
    m_errorBuffer += m_process->readAllStandardError();
}

QString ToolManager::formatDiffOutput(const QString &output) const
{
    QString escaped = output;
    escaped.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    
    QStringList lines = escaped.split('\n');
    QString formattedOutput = "<div style=\"white-space: pre; font-family: monospace;\">";
    
    for (const QString &line : lines) {
        if (line.startsWith('+')) {
            formattedOutput += "<font color=\"#228b22\">" + line + "</font><br>";
        } else if (line.startsWith('-')) {
            formattedOutput += "<font color=\"#cc0000\">" + line + "</font><br>";
        } else if (line.startsWith("@")) {
            formattedOutput += "<font color=\"#0000ff\">" + line + "</font><br>";
        } else {
            formattedOutput += line + "<br>";
        }
    }
    
    formattedOutput += "</div>";
    return formattedOutput;
}
