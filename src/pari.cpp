#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "filesystem.h"
#include "llm.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    FileSystem *fileSystem = new FileSystem(&app);
    fileSystem->model()->setRootPath(".");
    engine.rootContext()->setContextProperty("fileSystem", fileSystem);

    Llm *llm = new Llm(&app);
    engine.rootContext()->setContextProperty("llm", llm);

    const QUrl url(u"qrc:/qml/pari.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
