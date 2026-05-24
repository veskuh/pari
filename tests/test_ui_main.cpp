#include <QtQuickTest>
#include <QQmlEngine>
#include "textdocumentsearcher.h"
#include "gitlogmodel.h"
#include "gitblamemodel.h"
#include "gitdiffmodel.h"
#include "gitmanager.h"
#include "documentmanager.h"
#include "diffutils.h"
#include <QCoreApplication>

class Setup : public QObject
{
    Q_OBJECT
public:
    Setup() {}

public slots:
    void qmlEngineAvailable(QQmlEngine *engine)
    {
        engine->addImportPath("qrc:/qt-project.org/imports");
        engine->addImportPath(QCoreApplication::applicationDirPath() + "/../3rdparty/Kaakao/src");
        engine->addImportPath(QCoreApplication::applicationDirPath() + "/../../3rdparty/Kaakao/src");
        qmlRegisterType<DiffUtils>("net.veskuh.pari", 1, 0, "DiffUtils");
        qmlRegisterType<TextDocumentSearcher>("net.veskuh.pari", 1, 0, "TextDocumentSearcher");
        qmlRegisterType<GitLogModel>("net.veskuh.pari", 1, 0, "GitLogModel");
        qmlRegisterType<GitBlameModel>("net.veskuh.pari", 1, 0, "GitBlameModel");
        qmlRegisterType<GitDiffModel>("net.veskuh.pari", 1, 0, "GitDiffModel");
        qmlRegisterType<GitManager>("net.veskuh.pari", 1, 0, "GitManager");
        qmlRegisterType<DocumentManager>("net.veskuh.pari", 1, 0, "DocumentManager");
    }
};

QUICK_TEST_MAIN_WITH_SETUP(example, Setup)

#include "test_ui_main.moc"
