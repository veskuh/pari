#include <QtTest>
#include "test_diffutils.h"
#include "app/diffutils.h"

void TestDiffUtils::testNoChange()
{
    DiffUtils d;
    QString text1 = "line 1\nline 2\nline 3";
    QCOMPARE(d.createDiff(text1, text1), "  line 1<br>\n  line 2<br>\n  line 3<br>");
}

void TestDiffUtils::testSimpleAddition()
{
    DiffUtils d;
    QString text1 = "line 1\nline 3";
    QString text2 = "line 1\nline 2\nline 3";
    QCOMPARE(d.createDiff(text1, text2), "  line 1<br>\n<span style=\"color: green;\">+ line 2</span><br>\n  line 3<br>");
}

void TestDiffUtils::testSimpleDeletion()
{
    DiffUtils d;
    QString text1 = "line 1\nline 2\nline 3";
    QString text2 = "line 1\nline 3";
    QCOMPARE(d.createDiff(text1, text2), "  line 1<br>\n<span style=\"color: red;\">- line 2</span><br>\n  line 3<br>");
}

void TestDiffUtils::testModification()
{
    DiffUtils d;
    QString text1 = "line 1\nline two\nline 3";
    QString text2 = "line 1\nline 2\nline 3";
    QCOMPARE(d.createDiff(text1, text2), "  line 1<br>\n<span style=\"color: red;\">- line two</span><br>\n<span style=\"color: green;\">+ line 2</span><br>\n  line 3<br>");
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
    QCOMPARE(d.createDiff("", text), "<span style=\"color: green;\">+ line 1</span>\n<span style=\"color: green;\">+ line 2</span>");
}

void TestDiffUtils::testAllRemoved()
{
    DiffUtils d;
    QString text = "line 1\nline 2";
    QCOMPARE(d.createDiff(text, ""), "<span style=\"color: red;\">- line 1</span>\n<span style=\"color: red;\">- line 2</span>");
}

void TestDiffUtils::testComplexChanges()
{
    DiffUtils d;
    QString text1 = "line 1\nline 2\nline 3\nline 4\nline 5";
    QString text2 = "line 1\nline A\nline 3\nline B\nline 5";
    QString expected = "  line 1<br>\n<span style=\"color: red;\">- line 2</span><br>\n<span style=\"color: green;\">+ line A</span><br>\n  line 3<br>\n<span style=\"color: red;\">- line 4</span><br>\n<span style=\"color: green;\">+ line B</span><br>\n  line 5<br>";
    QCOMPARE(d.createDiff(text1, text2), expected);
}

void TestDiffUtils::testChangeAtStartAndEnd()
{
    DiffUtils d;
    QString text1 = "line 1\nline 2\nline 3";
    QString text2 = "line A\nline 2\nline C";
    QString expected = "<span style=\"color: red;\">- line 1</span><br>\n<span style=\"color: green;\">+ line A</span><br>\n  line 2<br>\n<span style=\"color: red;\">- line 3</span>\n<span style=\"color: green;\">+ line C</span>";
    QCOMPARE(d.createDiff(text1, text2), expected);
}

