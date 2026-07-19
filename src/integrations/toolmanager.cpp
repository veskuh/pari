#include "toolmanager.h"
#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <QTemporaryFile>
#include <QCoreApplication>
#include <QDir>

ToolManager::ToolManager(QObject *parent)
    : QObject{parent}, m_branchProcess(new QProcess(this)), m_qmlFormatProcess(new QProcess(this)), m_tempQmlFile(nullptr)
{
    connect(m_branchProcess, &QProcess::finished, this, &ToolManager::onBranchProcessFinished);
    connect(m_qmlFormatProcess, &QProcess::finished, this, &ToolManager::onQmlFormatProcessFinished);
}

void ToolManager::runCommand(const QString &command, const QString &workingDirectory)
{
    QProcess *process = new QProcess(this);
    process->setWorkingDirectory(workingDirectory);
    m_runningCommands.insert(process, {command, QByteArray(), QByteArray()});

    connect(process, &QProcess::readyReadStandardOutput, this, [this, process]() {
        auto it = m_runningCommands.find(process);
        if (it != m_runningCommands.end())
            it->outputBuffer += process->readAllStandardOutput();
    });
    connect(process, &QProcess::readyReadStandardError, this, [this, process]() {
        auto it = m_runningCommands.find(process);
        if (it != m_runningCommands.end())
            it->errorBuffer += process->readAllStandardError();
    });
    connect(process, qOverload<int, QProcess::ExitStatus>(&QProcess::finished), this, [this, process](int, QProcess::ExitStatus) {
        auto it = m_runningCommands.find(process);
        if (it == m_runningCommands.end()) {
            process->deleteLater();
            return;
        }
        CommandContext ctx = it.value();
        m_runningCommands.erase(it);
        dispatchCommandOutput(ctx);
        process->deleteLater();
    });
    connect(process, &QProcess::errorOccurred, this, [this, process](QProcess::ProcessError error) {
        if (error != QProcess::FailedToStart)
            return;
        if (m_runningCommands.contains(process)) {
            CommandContext ctx = m_runningCommands.take(process);
            dispatchCommandOutput(ctx);
            process->deleteLater();
        }
    });

    process->start("sh", QStringList() << "-c" << command);
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

void ToolManager::dispatchCommandOutput(const CommandContext &ctx)
{
    const QString &command = ctx.command;
    const QString output = QString::fromUtf8(ctx.outputBuffer);
    const QString error = QString::fromUtf8(ctx.errorBuffer);

    qDebug() << "ToolManager: Process finished. Command:" << command << "Output size:" << output.size();

    if (command.startsWith("git log")) {
        emit gitLogReady(output);
    } else if (command.contains("git show --stat")) {
        QString sha = command.split(" ").last();
        emit commitDetailsReady(sha, output);
    } else if (command.contains("git diff") || command.contains("git show")) {
        emit gitDiffReady(output);
        emit outputReady(command, formatDiffOutput(output), m_branchName);
    } else if (command.contains("git blame")) {
        emit outputReady(command, output, m_branchName);
    } else {
        emit outputReady(command, output.isEmpty() ? error : output, m_branchName);
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
