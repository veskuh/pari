#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "filesystem.h"
#include "llm.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("veskuh.net");
    app.setOrganizationDomain("veskuh.net");
    app.setApplicationName("Pari");

    QQmlApplicationEngine engine;

    FileSystem *fileSystem = new FileSystem(&app);   
    engine.rootContext()->setContextProperty("fileSystem", fileSystem);

    Llm *llm = new Llm(&app);
    engine.rootContext()->setContextProperty("llm", static_cast<QObject*>(llm));

    const QUrl url("qrc:/qml/pari.qml");
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);
    return app.exec();
}
