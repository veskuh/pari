#ifndef TOOLMANAGER_H
#define TOOLMANAGER_H

#include <QObject>
#include <QProcess>
#include <QString>
#include <QTemporaryFile>

class ToolManager : public QObject
{
    Q_OBJECT
public:
    explicit ToolManager(QObject *parent = nullptr);

    Q_INVOKABLE void runCommand(const QString &command, const QString &workingDirectory);
    Q_INVOKABLE void indentQmlFile(const QString &filePath, const QString &content);

signals:
    void outputReady(const QString &command, const QString &output, const QString &branchName);
    void qmlFileIndented(const QString &formattedContent);
    void gitLogReady(const QString &log);

private slots:
    void onBranchProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void onReadyReadStandardOutput();
    void onReadyReadStandardError();
    void onQmlFormatProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    QString formatDiffOutput(const QString &output) const;
    QProcess *m_branchProcess;
    QProcess *m_process;
    QProcess *m_qmlFormatProcess;
    QString m_command;
    QString m_workingDirectory;
    QString m_branchName;
    QString m_originalQmlContent;
    QTemporaryFile *m_tempQmlFile;
};

#endif // TOOLMANAGER_H
