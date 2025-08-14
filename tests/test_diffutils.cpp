#include <QtTest>
#include "test_diffutils.h"
#include "app/diffutils.h"

void TestDiffUtils::testNoChange()
{
    DiffUtils d;
    QString text1 = "line 1\nline 2\nline 3";
    QString text2 = "line 1\nline 2\nline 3";
    QString expected = "  line 1\n  line 2\n  line 3";
    QCOMPARE(d.createDiff(text1, text2), expected);
}

void TestDiffUtils::testSimpleAddition()
{
    DiffUtils d;
    QString text1 = "line 1\nline 3";
    QString text2 = "line 1\nline 2\nline 3";
    // The simple diff algorithm shows removals first, then additions.
    QString expected = "  line 1\n- line 3\n+ line 2\n+ line 3";
    QCOMPARE(d.createDiff(text1, text2), "  line 1\n+ line 2\n  line 3");
}

void TestDiffUtils::testSimpleDeletion()
{
    DiffUtils d;
    QString text1 = "line 1\nline 2\nline 3";
    QString text2 = "line 1\nline 3";
    QString expected = "  line 1\n- line 2\n  line 3";
    QCOMPARE(d.createDiff(text1, text2), expected);
}

void TestDiffUtils::testModification()
{
    DiffUtils d;
    QString text1 = "line 1\nline two\nline 3";
    QString text2 = "line 1\nline 2\nline 3";
    QString expected = "  line 1\n- line two\n+ line 2\n  line 3";
    QCOMPARE(d.createDiff(text1, text2), expected);
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
    QString expected = "+ line 1\n+ line 2";
    QCOMPARE(d.createDiff("", text), expected);
}

void TestDiffUtils::testAllRemoved()
{
    DiffUtils d;
    QString text = "line 1\nline 2";
    QString expected = "- line 1\n- line 2";
    QCOMPARE(d.createDiff(text, ""), expected);
}
