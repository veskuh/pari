#include <QGuiApplication>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QPalette>
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
#include "gitmanager.h"
#include "../editor/editormanager.h"

int main(int argc, char *argv[])
{
    qRegisterMetaType<SyntaxTheme>();

    qmlRegisterType<EditorManager>("net.veskuh.pari", 1, 0, "EditorManager");
    qmlRegisterType<Document>("net.veskuh.pari", 1, 0, "Document");

    QGuiApplication app(argc, argv);
    app.setOrganizationName("veskuh.net");
    app.setOrganizationDomain("veskuh.net");
    app.setApplicationName("Pari");

    qmlRegisterType<DiffUtils>("net.veskuh.pari", 1, 0, "DiffUtils");
    qmlRegisterType<TextDocumentSearcher>("net.veskuh.pari", 1, 0, "TextDocumentSearcher");
    qmlRegisterType<GitLogModel>("net.veskuh.pari", 1, 0, "GitLogModel");
    qmlRegisterType<GitManager>("net.veskuh.pari", 1, 0, "GitManager");

    QQmlApplicationEngine engine;

    Settings *appSettings = new Settings(&app);
    appSettings->setSystemTheme(QApplication::palette().color(QPalette::Window).lightness() < 128);
    engine.rootContext()->setContextProperty("appSettings", appSettings);

    FileSystem *fileSystem = new FileSystem(&app);
    engine.rootContext()->setContextProperty("fileSystem", fileSystem);

    EditorManager *editorManager = new EditorManager(&app);
    engine.rootContext()->setContextProperty("editorManager", editorManager);

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

    GitManager *gitManager = new GitManager(&app);
    engine.rootContext()->setContextProperty("gitManager", gitManager);

    QObject::connect(fileSystem, &FileSystem::projectOpened, gitManager, [gitManager, fileSystem](){
        gitManager->setWorkingDirectory(fileSystem->rootPath());
        gitManager->refresh();
    });

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
