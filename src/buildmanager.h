#ifndef BUILDMANAGER_H
#define BUILDMANAGER_H

#include <QObject>
#include <QProcess>
#include <QString>

class BuildManager : public QObject
{
    Q_OBJECT
public:
    explicit BuildManager(QObject *parent = nullptr);

    Q_INVOKABLE void executeCommand(const QString &command, const QString &workingDirectory);

signals:
    void outputReady(const QString &output);
    void errorReady(const QString &error);
    void finished();

private slots:
    void onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void onReadyReadStandardOutput();
    void onReadyReadStandardError();
    void onErrorOccurred(QProcess::ProcessError error);

private:
    QProcess *m_process;
};

#endif // BUILDMANAGER_H
