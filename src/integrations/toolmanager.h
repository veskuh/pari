#ifndef TOOLMANAGER_H
#define TOOLMANAGER_H

#include <QObject>
#include <QProcess>
#include <QString>
#include <QTemporaryFile>
#include <QHash>

class ToolManager : public QObject
{
    Q_OBJECT
public:
    explicit ToolManager(QObject *parent = nullptr);

    Q_INVOKABLE void runCommand(const QString &command, const QString &workingDirectory);
    Q_INVOKABLE void indentQmlFile(const QString &filePath, const QString &content);
    Q_INVOKABLE void getBranchName(const QString &workingDirectory);

signals:
    void outputReady(const QString &command, const QString &output, const QString &branchName);
    void qmlFileIndented(const QString &formattedContent);
    void gitLogReady(const QString &log);
    void gitDiffReady(const QString &diff);
    void commitDetailsReady(const QString &sha, const QString &details);

private slots:
    void onBranchProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void onQmlFormatProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    struct CommandContext {
        QString command;
        QByteArray outputBuffer;
        QByteArray errorBuffer;
    };

    QString formatDiffOutput(const QString &output) const;
    void dispatchCommandOutput(const CommandContext &ctx);
    QProcess *m_branchProcess;
    QProcess *m_qmlFormatProcess;
    QHash<QProcess*, CommandContext> m_runningCommands;
    QString m_branchName;
    QString m_originalQmlContent;
    QTemporaryFile *m_tempQmlFile;
};

#endif // TOOLMANAGER_H
