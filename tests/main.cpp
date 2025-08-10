#include <QtTest>
#include "test_settings.h"
#include "test_filesystem.h"
#include "test_markdownformatter.h"

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

    return status;
}
