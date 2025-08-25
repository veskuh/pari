#ifndef TEST_GITLOGMODEL_H
#define TEST_GITLOGMODEL_H

#include <QObject>

class TestGitLogModel : public QObject
{
    Q_OBJECT

private slots:
    void testParsing();
    void testEmptyLog();
    void testCommitWithoutBody();
};

#endif // TEST_GITLOGMODEL_H
