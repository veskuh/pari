#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "filesystem.h"
#include "llm.h"
#include "settings.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("veskuh.net");
    app.setOrganizationDomain("veskuh.net");
    app.setApplicationName("Pari");

    QQmlApplicationEngine engine;

    Settings *appSettings = new Settings(&app);
    engine.rootContext()->setContextProperty("appSettings", appSettings);

    FileSystem *fileSystem = new FileSystem(appSettings, &app);
    engine.rootContext()->setContextProperty("fileSystem", fileSystem);

    Llm *llm = new Llm(appSettings, &app);
    engine.rootContext()->setContextProperty("llm", static_cast<QObject*>(llm));

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
