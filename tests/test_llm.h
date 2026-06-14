#ifndef TEST_LLM_H
#define TEST_LLM_H

#include <QObject>
#include <QTcpServer>
#include <QTcpSocket>

class MockOllamaServer : public QTcpServer {
    Q_OBJECT
public:
    explicit MockOllamaServer(QObject *parent = nullptr);
    void setResponse(const QByteArray &data);
    QString url() const;

protected:
    void incomingConnection(qintptr socketDescriptor) override;

private:
    QByteArray m_responseData;
};

class TestLlm : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void testSendPromptAddsToLog();
    void testSuccessfulResponse();
    void testStreamingResponse();
    void testErrorResponse();
    void testSettingsChangeAddsToLog();
    void testListModels();
    void testListModelsFailure();

private:
    MockOllamaServer *m_mockServer;
};

#endif // TEST_LLM_H
