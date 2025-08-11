#ifndef TEST_LLM_H
#define TEST_LLM_H

#include <QObject>

class TestLlm : public QObject
{
    Q_OBJECT

private slots:
    void init();
    void cleanup();
    void testSendPromptAddsToLog();
    void testSuccessfulResponseAddsToLog();
    void testErrorResponseAddsToLog();
    void testSettingsChangeAddsToLog();
};

#endif // TEST_LLM_H
