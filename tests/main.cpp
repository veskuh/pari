#include <QtTest>
#include "test_settings.h"
#include "test_filesystem.h"
#include "test_markdownformatter.h"
#include "test_llm.h"
#include "test_cppsyntaxhighlighter.h"
#include "test_qmlsyntaxhighlighter.h"
#include "test_shellsyntaxhighlighter.h"
#include "test_diffutils.h"
#include "test_buildmanager.h"
#include "test_toolmanager.h"
#include "test_gitlogmodel.h"

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    int status = 0;

    TestSettings tc_settings;
    status |= QTest::qExec(&tc_settings, argc, argv);

    TestFileSystem tc_fs;
    status |= QTest::qExec(&tc_fs, argc, argv);

    TestMarkdownFormatter tc_md;
    status |= QTest::qExec(&tc_md, argc, argv);

    TestLlm tc_llm;
    status |= QTest::qExec(&tc_llm, argc, argv);

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

    return status;
}
