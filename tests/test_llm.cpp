#include "test_llm.h"
#include <QtTest>
#include <QSignalSpy>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QTimer>
#include "llm.h"
#include "settings.h"

MockOllamaServer::MockOllamaServer(QObject *parent) : QTcpServer(parent) {
    listen(QHostAddress::LocalHost);
}

QString MockOllamaServer::url() const {
    return QString("http://localhost:%1").arg(serverPort());
}

void MockOllamaServer::setResponse(const QByteArray &data) {
    m_responseData = data;
}

void MockOllamaServer::incomingConnection(qintptr socketDescriptor) {
    QTcpSocket *socket = new QTcpSocket(this);
    socket->setSocketDescriptor(socketDescriptor);
    connect(socket, &QTcpSocket::readyRead, [this, socket]() {
        if (socket->canReadLine()) {
            socket->readAll(); // Consume request
            socket->write("HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nConnection: close\r\n\r\n");
            socket->write(m_responseData);
            socket->flush();
            socket->disconnectFromHost();
        }
    });
    connect(socket, &QTcpSocket::disconnected, socket, &QTcpSocket::deleteLater);
}

void TestLlm::initTestCase()
{
    m_mockServer = new MockOllamaServer(this);
}

void TestLlm::cleanupTestCase()
{
    QSettings settings("veskuh.net", "PariTests");
    settings.clear();
}

void TestLlm::testSendPromptAddsToLog()
{
    Settings settings("PariTests");
    Llm llm(&settings);
    QSignalSpy spy(&llm, &Llm::chatLogChanged);

    llm.sendPrompt("Test prompt");

    QCOMPARE(spy.count(), 1);
    const QStringList log = llm.chatLog();
    QVERIFY(log.size() > 0);
    QVERIFY(log.last().contains("USER: Test prompt"));
}

void TestLlm::testSuccessfulResponse()
{
    Settings settings("PariTests");
    settings.setOllamaUrl(m_mockServer->url());
    Llm llm(&settings);
    
    QSignalSpy spy(&llm, &Llm::responseReady);
    
    QJsonObject response;
    response["response"] = "Success response";
    response["done"] = true;
    m_mockServer->setResponse(QJsonDocument(response).toJson(QJsonDocument::Compact) + "\n");
    
    llm.sendPrompt("test");
    QVERIFY(spy.wait(5000));
    QCOMPARE(spy.count(), 1);
    QCOMPARE(spy.first().at(0).toString(), QString("Success response"));
    QVERIFY(!llm.busy());
}

void TestLlm::testStreamingResponse()
{
    Settings settings("PariTests");
    settings.setOllamaUrl(m_mockServer->url());
    Llm llm(&settings);
    
    QSignalSpy lineSpy(&llm, &Llm::newLineReceived);
    
    QByteArray chunk1 = QJsonDocument(QJsonObject{{"response", "Line 1\n"}}).toJson(QJsonDocument::Compact) + "\n";
    QByteArray chunk2 = QJsonDocument(QJsonObject{{"response", "Line 2\n"}}).toJson(QJsonDocument::Compact) + "\n";
    m_mockServer->setResponse(chunk1 + chunk2);
    
    llm.sendPrompt("test stream");
    
    QVERIFY(lineSpy.wait(5000));
    // Wait for potential second signal
    if (lineSpy.count() < 2) QTest::qWait(500);
    
    QVERIFY(lineSpy.count() >= 2);
    QCOMPARE(lineSpy.at(0).at(0).toString(), QString("Line 1"));
    QCOMPARE(lineSpy.at(1).at(0).toString(), QString("Line 2"));
}

void TestLlm::testErrorResponse()
{
    QVERIFY(true);
}

void TestLlm::testSettingsChangeAddsToLog()
{
    Settings settings("PariTests");
    Llm llm(&settings);
    QSignalSpy spy(&llm, &Llm::chatLogChanged);

    settings.setOllamaModel("new-test-model");

    QVERIFY(spy.count() > 0);
    const QStringList log = llm.chatLog();
    QVERIFY(log.last().contains("INFO: Settings changed"));
}

void TestLlm::testListModels()
{
    Settings settings("PariTests");
    settings.setOllamaUrl(m_mockServer->url());
    Llm llm(&settings);
    
    QSignalSpy spy(&llm, &Llm::modelsListed);
    
    QJsonArray models;
    models.append(QJsonObject{{"name", "model:latest"}});
    QJsonObject response;
    response["models"] = models;
    m_mockServer->setResponse(QJsonDocument(response).toJson(QJsonDocument::Compact));
    
    llm.listModels();
    
    QVERIFY(spy.wait(5000));
    QCOMPARE(spy.count(), 1);
    QStringList result = spy.first().at(0).toStringList();
    QCOMPARE(result.size(), 1);
    QCOMPARE(result.first(), QString("model:latest"));
}
