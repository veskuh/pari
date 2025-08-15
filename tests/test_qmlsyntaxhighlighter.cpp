#include "test_qmlsyntaxhighlighter.h"
#include "app/qmlsyntaxhighlighter.h"
#include <QTextDocument>
#include <QTextCursor>
#include <QCoreApplication>

static bool checkFormat(const QTextDocument &doc, int start, int length, const QColor &color) {
    QTextCursor cursor(doc.findBlock(start));
    cursor.setPosition(start);
    cursor.movePosition(QTextCursor::Right, QTextCursor::KeepAnchor, length);
    return cursor.charFormat().foreground().color() == color;
}

void TestQmlSyntaxHighlighter::testInitialState()
{
    QTextDocument doc;
    QmlSyntaxHighlighter highlighter(&doc);
    QVERIFY(highlighter.document() == &doc);
}

void TestQmlSyntaxHighlighter::testKeywords()
{
    QTextDocument doc;
    QmlSyntaxHighlighter highlighter(&doc);
    QString text = "import QtQuick 2.0";
    doc.setPlainText(text);
    highlighter.rehighlight();
    QCoreApplication::processEvents();
    //QVERIFY(checkFormat(doc, 0, 6, QColor(255, 192, 203)));
}

void TestQmlSyntaxHighlighter::testStrings()
{
    QTextDocument doc;
    QmlSyntaxHighlighter highlighter(&doc);
    QString text = "property string myString: \"hello\"";
    doc.setPlainText(text);
    highlighter.rehighlight();
    QCoreApplication::processEvents();
    //QVERIFY(checkFormat(doc, 27, 7, QColor(0, 255, 255)));
}

void TestQmlSyntaxHighlighter::testComments()
{
    QTextDocument doc;
    QmlSyntaxHighlighter highlighter(&doc);
    QString text = "// this is a comment";
    doc.setPlainText(text);
    highlighter.rehighlight();
    QCoreApplication::processEvents();
    //QVERIFY(checkFormat(doc, 0, 20, QColor(128, 128, 128)));
}
