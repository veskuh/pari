#ifndef GITMANAGER_H
#define GITMANAGER_H

#include <QObject>
#include <QString>
#include <QProcess>

class GitManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentBranch READ currentBranch WRITE setCurrentBranch NOTIFY currentBranchChanged)

public:
    explicit GitManager(QObject *parent = nullptr);
    ~GitManager();

    void setWorkingDirectory(const QString &path);

    QString currentBranch() const;

public slots:
    void refresh();

signals:
    void currentBranchChanged();

private slots:
    void onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    void setCurrentBranch(const QString &currentBranch);

    QString m_currentBranch;
    QProcess *m_process;
};

#endif // GITMANAGER_H
