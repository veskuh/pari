#include <QtTest>
#include "test_diffutils.h"
#include "app/diffutils.h"

void TestDiffUtils::testNoChange()
{
    DiffUtils d;
    QString text1 = "line 1\nline 2\nline 3";
    QCOMPARE(d.createDiff(text1, text1), "  line 1\n  line 2\n  line 3");
}

void TestDiffUtils::testSimpleAddition()
{
    DiffUtils d;
    QString text1 = "line 1\nline 3";
    QString text2 = "line 1\nline 2\nline 3";
    QCOMPARE(d.createDiff(text1, text2), "  line 1\n+ line 2\n  line 3");
}

void TestDiffUtils::testSimpleDeletion()
{
    DiffUtils d;
    QString text1 = "line 1\nline 2\nline 3";
    QString text2 = "line 1\nline 3";
    QCOMPARE(d.createDiff(text1, text2), "  line 1\n- line 2\n  line 3");
}

void TestDiffUtils::testModification()
{
    DiffUtils d;
    QString text1 = "line 1\nline two\nline 3";
    QString text2 = "line 1\nline 2\nline 3";
    QCOMPARE(d.createDiff(text1, text2), "  line 1\n- line two\n+ line 2\n  line 3");
}

void TestDiffUtils::testEmptyInputs()
{
    DiffUtils d;
    QCOMPARE(d.createDiff("", ""), "");
}

void TestDiffUtils::testAllAdded()
{
    DiffUtils d;
    QString text = "line 1\nline 2";
    QCOMPARE(d.createDiff("", text), "+ line 1\n+ line 2");
}

void TestDiffUtils::testAllRemoved()
{
    DiffUtils d;
    QString text = "line 1\nline 2";
    QCOMPARE(d.createDiff(text, ""), "- line 1\n- line 2");
}

void TestDiffUtils::testComplexChanges()
{
    DiffUtils d;
    QString text1 = "line 1\nline 2\nline 3\nline 4\nline 5";
    QString text2 = "line 1\nline A\nline 3\nline B\nline 5";
    QString expected = "  line 1\n- line 2\n+ line A\n  line 3\n- line 4\n+ line B\n  line 5";
    QCOMPARE(d.createDiff(text1, text2), expected);
}

void TestDiffUtils::testChangeAtStartAndEnd()
{
    DiffUtils d;
    QString text1 = "line 1\nline 2\nline 3";
    QString text2 = "line A\nline 2\nline C";
    QString expected = "- line 1\n+ line A\n  line 2\n- line 3\n+ line C";
    QCOMPARE(d.createDiff(text1, text2), expected);
}
