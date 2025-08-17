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

int main(int argc, char *argv[])
{
    qRegisterMetaType<SyntaxTheme>();

    QGuiApplication app(argc, argv);
    app.setOrganizationName("veskuh.net");
    app.setOrganizationDomain("veskuh.net");
    app.setApplicationName("Pari");

    qmlRegisterType<DiffUtils>("net.veskuh.pari", 1, 0, "DiffUtils");
    qmlRegisterType<TextDocumentSearcher>("net.veskuh.pari", 1, 0, "TextDocumentSearcher");

    QQmlApplicationEngine engine;

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

    const QUrl url("qrc:/qml/pari.qml");

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
