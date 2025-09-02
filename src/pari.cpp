#include <QGuiApplication>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QPalette>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QLoggingCategory>

#include "filesystem.h"
#include "llm.h"
#include "settings.h"
#include "syntaxhighlighterprovider.h"
#include "diffutils.h"
#include "textdocumentsearcher.h"
#include "syntaxtheme.h"
#include "buildmanager.h"
#include "toolmanager.h"
#include "gitlogmodel.h"
#include "lspclient.h"
#include "lsploghandler.h"

static LspLogHandler *lspLogHandler = nullptr;
static QMessageLogger *logger = nullptr;

#include <cstring>

void lspMessageOutput(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    if (strcmp(context.category, "pari.lsp") == 0) {
        if (type == QtDebugMsg) {
            if (lspLogHandler) {
                lspLogHandler->addMessage(msg);
            }
        } else {
            (*qt_message_output)(type, context, msg);
        }
    } else {
        (*qt_message_output)(type, context, msg);
    }
}

int main(int argc, char *argv[])
{
    qRegisterMetaType<SyntaxTheme>();

    QGuiApplication app(argc, argv);
    app.setOrganizationName("veskuh.net");
    app.setOrganizationDomain("veskuh.net");
    app.setApplicationName("Pari");

    QCommandLineParser parser;
    parser.setApplicationDescription("Pari");
    parser.addHelpOption();
    QCommandLineOption debugOption("debug", "Enable debug mode.");
    parser.addOption(debugOption);
    QCommandLineOption selfcheckOption("selfcheck", "Run QML self-check.");
    parser.addOption(selfcheckOption);
    parser.process(app);

    bool isDebug = parser.isSet(debugOption);
    if (isDebug) {
        lspLogHandler = new LspLogHandler(&app);
        qInstallMessageHandler(lspMessageOutput);
    } else {
        QLoggingCategory::setFilterRules("pari.lsp.debug=false");
    }

    qmlRegisterType<DiffUtils>("net.veskuh.pari", 1, 0, "DiffUtils");
    qmlRegisterType<TextDocumentSearcher>("net.veskuh.pari", 1, 0, "TextDocumentSearcher");
    qmlRegisterType<GitLogModel>("net.veskuh.pari", 1, 0, "GitLogModel");

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("lspLogHandler", lspLogHandler);
    engine.rootContext()->setContextProperty("debugMode", isDebug);

    Settings *appSettings = new Settings(&app);
    appSettings->setSystemTheme(QApplication::palette().color(QPalette::Window).lightness() < 128);
    engine.rootContext()->setContextProperty("appSettings", appSettings);

    FileSystem *fileSystem = new FileSystem(&app);
    engine.rootContext()->setContextProperty("fileSystem", fileSystem);

    Llm *llm = new Llm(appSettings, &app);
    engine.rootContext()->setContextProperty("llm", static_cast<QObject*>(llm));

    SyntaxHighlighterProvider *syntaxHighlighterProvider = new SyntaxHighlighterProvider(&app);
    engine.rootContext()->setContextProperty("syntaxHighlighterProvider", syntaxHighlighterProvider);
    syntaxHighlighterProvider->setSettings(appSettings);

    BuildManager *buildManager = new BuildManager(&app);
    engine.rootContext()->setContextProperty("buildManager", buildManager);

    ToolManager *toolManager = new ToolManager(&app);
    engine.rootContext()->setContextProperty("toolManager", toolManager);

    LspClient *lspClient = new LspClient(&app);
    engine.rootContext()->setContextProperty("lspClient", lspClient);

    QObject::connect(fileSystem, &FileSystem::projectOpened, lspClient, &LspClient::startServer);

    const QUrl url("qrc:/qml/PariAppWindow.qml");

    if (app.arguments().contains("--selfcheck")) {
        QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
            &app, [url](QObject *obj, const QUrl &objUrl) {
                if (!obj && url == objUrl) {
                    QCoreApplication::exit(-1);
                } else {
                    QCoreApplication::exit(0);
                }
            }, Qt::QueuedConnection);
    } else {
        QObject::connect(llm, &Llm::modelsListed, appSettings, &Settings::setAvailableModels);
        llm->listModels();

        QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
            &app, [url](QObject *obj, const QUrl &objUrl) {
                if (!obj && url == objUrl)
                    QCoreApplication::exit(-1);
            }, Qt::QueuedConnection);
    }

    engine.load(url);
    return app.exec();
}
