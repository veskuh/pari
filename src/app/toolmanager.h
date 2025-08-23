#ifndef TOOLMANAGER_H
#define TOOLMANAGER_H

#include <QObject>
#include <QProcess>
#include <QString>

class ToolManager : public QObject
{
    Q_OBJECT
public:
    explicit ToolManager(QObject *parent = nullptr);

    Q_INVOKABLE void runCommand(const QString &command, const QString &workingDirectory);

signals:
    void outputReady(const QString &command, const QString &output, const QString &branchName);

private slots:
    void onBranchProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void onReadyReadStandardOutput();
    void onReadyReadStandardError();

private:
    QProcess *m_branchProcess;
    QProcess *m_process;
    QString m_command;
    QString m_workingDirectory;
    QString m_branchName;
};

#endif // TOOLMANAGER_H
