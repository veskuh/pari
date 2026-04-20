#include <QtQuickTest>
#include <QQmlEngine>
#include "textdocumentsearcher.h"
#include "gitlogmodel.h"
#include "gitblamemodel.h"
#include "gitmanager.h"
#include "documentmanager.h"
#include "diffutils.h"

class Setup : public QObject
{
    Q_OBJECT
public:
    Setup() {}

public slots:
    void qmlEngineAvailable(QQmlEngine *engine)
    {
        qmlRegisterType<DiffUtils>("net.veskuh.pari", 1, 0, "DiffUtils");
        qmlRegisterType<TextDocumentSearcher>("net.veskuh.pari", 1, 0, "TextDocumentSearcher");
        qmlRegisterType<GitLogModel>("net.veskuh.pari", 1, 0, "GitLogModel");
        qmlRegisterType<GitBlameModel>("net.veskuh.pari", 1, 0, "GitBlameModel");
        qmlRegisterType<GitManager>("net.veskuh.pari", 1, 0, "GitManager");
        qmlRegisterType<DocumentManager>("net.veskuh.pari", 1, 0, "DocumentManager");
    }
};

QUICK_TEST_MAIN_WITH_SETUP(example, Setup)

#include "test_ui_main.moc"
