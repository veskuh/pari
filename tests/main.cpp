#include <QtTest>
#include "test_settings.h"
#include "test_filesystem.h"
#include "test_markdownformatter.h"
#include "test_llm.h"
#include "test_cppsyntaxhighlighter.h"
#include "test_diffutils.h"

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

    TestDiffUtils tc_diff;
    status |= QTest::qExec(&tc_diff, argc, argv);

    return status;
}
