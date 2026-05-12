#include <QtTest>
#include <QApplication>
#include <QQmlEngine>
#include "test_settings.h"
#include "test_clipboardhelper.h"
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
#include "test_gitblamemodel.h"
#include "test_gitmanager.h"
#include "test_documentmanager.h"
#include "test_syntaxtheme.h"
#include "test_cppsyntaxhighlighter.h"
#include "test_swiftsyntaxhighlighter.h"
#include "test_jssyntaxhighlighter.h"
#include "test_javasyntaxhighlighter.h"
#include "test_kotlinsyntaxhighlighter.h"
#include "test_projectsearchmodel.h"
#include "test_syntaxhighlighterprovider.h"
#include "test_rustsyntaxhighlighter.h"
#include "test_gosyntaxhighlighter.h"
#include "test_textdocumentsearcher.h"

#include "diffutils.h"
#include "textdocumentsearcher.h"
#include "gitlogmodel.h"
#include "gitblamemodel.h"
#include "gitmanager.h"
#include "documentmanager.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setOrganizationName("veskuh.net");
    app.setApplicationName("PariTests");
    
    qmlRegisterType<DiffUtils>("net.veskuh.pari", 1, 0, "DiffUtils");
    qmlRegisterType<TextDocumentSearcher>("net.veskuh.pari", 1, 0, "TextDocumentSearcher");
    qmlRegisterType<GitLogModel>("net.veskuh.pari", 1, 0, "GitLogModel");
    qmlRegisterType<GitBlameModel>("net.veskuh.pari", 1, 0, "GitBlameModel");
    qmlRegisterType<GitManager>("net.veskuh.pari", 1, 0, "GitManager");
    qmlRegisterType<DocumentManager>("net.veskuh.pari", 1, 0, "DocumentManager");

    int status = 0;

    TestSettings tc_settings;
    status |= QTest::qExec(&tc_settings, argc, argv);

    TestClipboardHelper tc_clipboard;
    status |= QTest::qExec(&tc_clipboard, argc, argv);

    TestFileSystem tc_filesystem;
    status |= QTest::qExec(&tc_filesystem, argc, argv);

    TestMarkdownFormatter tc_markdown;
    status |= QTest::qExec(&tc_markdown, argc, argv);

    TestLlm tc_llm;
    status |= QTest::qExec(&tc_llm, argc, argv);

    TestMarkdownSyntaxHighlighter tc_markdown_highlighter;
    status |= QTest::qExec(&tc_markdown_highlighter, argc, argv);

    TestQmlSyntaxHighlighter tc_qml_highlighter;
    status |= QTest::qExec(&tc_qml_highlighter, argc, argv);

    TestDiffUtils tc_diff;
    status |= QTest::qExec(&tc_diff, argc, argv);

    TestShellSyntaxHighlighter tc_shell_highlighter;
    status |= QTest::qExec(&tc_shell_highlighter, argc, argv);

    TestBuildManager tc_build;
    status |= QTest::qExec(&tc_build, argc, argv);

    TestToolManager tc_tool;
    status |= QTest::qExec(&tc_tool, argc, argv);

    TestGitLogModel tc_git;
    status |= QTest::qExec(&tc_git, argc, argv);

    TestGitBlameModel tc_blame;
    status |= QTest::qExec(&tc_blame, argc, argv);

    TestGitManager tc_git_manager;
    status |= QTest::qExec(&tc_git_manager, argc, argv);

    TestDocumentManager tc_doc_manager;
    status |= QTest::qExec(&tc_doc_manager, argc, argv);

    TestSyntaxTheme tc_theme;
    status |= QTest::qExec(&tc_theme, argc, argv);

    TestCppSyntaxHighlighter tc_cpp_highlighter;
    status |= QTest::qExec(&tc_cpp_highlighter, argc, argv);

    TestSwiftSyntaxHighlighter tc_swift_highlighter;
    status |= QTest::qExec(&tc_swift_highlighter, argc, argv);

    TestJsSyntaxHighlighter tc_js_highlighter;
    status |= QTest::qExec(&tc_js_highlighter, argc, argv);

    TestJavaSyntaxHighlighter tc_java_highlighter;
    status |= QTest::qExec(&tc_java_highlighter, argc, argv);

    TestKotlinSyntaxHighlighter tc_kotlin_highlighter;
    status |= QTest::qExec(&tc_kotlin_highlighter, argc, argv);

    TestSyntaxHighlighterProvider tc_provider;
    status |= QTest::qExec(&tc_provider, argc, argv);

    TestProjectSearchModel tc_search_model;
    status |= QTest::qExec(&tc_search_model, argc, argv);

    TestRustSyntaxHighlighter tc_rust_highlighter;
    status |= QTest::qExec(&tc_rust_highlighter, argc, argv);

    TestGoSyntaxHighlighter tc_go_highlighter;
    status |= QTest::qExec(&tc_go_highlighter, argc, argv);

    TestTextDocumentSearcher tc_searcher;
    status |= QTest::qExec(&tc_searcher, argc, argv);

    return status;
}
