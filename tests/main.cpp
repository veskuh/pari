#include <QtTest>
#include <QQmlEngine>
#include "test_settings.h"
#include "test_filesystem.h"
#include "test_markdownformatter.h"
#include "test_llm.h"
#include "test_markdownsyntaxhighlighter.h"
#include "test_qmlsyntaxhighlighter.h"
#include "test_shellsyntaxhighlighter.h"
#include "test_diffutils.h"
#include "test_buildmanager.h"
#include "test_toolmanager.h"
#include "test_gitlogmodel.h"
#include "test_gitmanager.h"
#include "test_documentmanager.h"
#include "test_syntaxtheme.h"
#include "test_cppsyntaxhighlighter.h"
#include "test_textdocumentsearcher.h"

#include "textdocumentsearcher.h"
#include "gitlogmodel.h"
#include "gitmanager.h"
#include "documentmanager.h"

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    app.setOrganizationName("veskuh.net");
    app.setApplicationName("PariTests");
    
    qmlRegisterType<TextDocumentSearcher>("net.veskuh.pari", 1, 0, "TextDocumentSearcher");
    qmlRegisterType<GitLogModel>("net.veskuh.pari", 1, 0, "GitLogModel");
    qmlRegisterType<GitManager>("net.veskuh.pari", 1, 0, "GitManager");
    qmlRegisterType<DocumentManager>("net.veskuh.pari", 1, 0, "DocumentManager");

    int status = 0;

    TestSettings tc_settings;
    status |= QTest::qExec(&tc_settings, argc, argv);

    TestFileSystem tc_fs;
    status |= QTest::qExec(&tc_fs, argc, argv);

    TestMarkdownFormatter tc_md;
    status |= QTest::qExec(&tc_md, argc, argv);

    TestLlm tc_llm;
    status |= QTest::qExec(&tc_llm, argc, argv);

    TestMarkdownSyntaxHighlighter tc_md_syntax;
    status |= QTest::qExec(&tc_md_syntax, argc, argv);

    TestQmlSyntaxHighlighter tc_qml;
    status |= QTest::qExec(&tc_qml, argc, argv);

    TestDiffUtils tc_diff;
    status |= QTest::qExec(&tc_diff, argc, argv);

    TestShellSyntaxHighlighter tc_shell;
    status |= QTest::qExec(&tc_shell, argc, argv);

    TestBuildManager tc_build;
    status |= QTest::qExec(&tc_build, argc, argv);

    TestToolManager tc_tool;
    status |= QTest::qExec(&tc_tool, argc, argv);

    TestGitLogModel tc_git;
    status |= QTest::qExec(&tc_git, argc, argv);

    TestGitManager tc_git_manager;
    status |= QTest::qExec(&tc_git_manager, argc, argv);

    TestDocumentManager tc_doc_manager;
    status |= QTest::qExec(&tc_doc_manager, argc, argv);

    TestSyntaxTheme tc_theme;
    status |= QTest::qExec(&tc_theme, argc, argv);

    TestCppSyntaxHighlighter tc_cpp_highlighter;
    status |= QTest::qExec(&tc_cpp_highlighter, argc, argv);

    TestTextDocumentSearcher tc_searcher;
    status |= QTest::qExec(&tc_searcher, argc, argv);

    return status;
}
