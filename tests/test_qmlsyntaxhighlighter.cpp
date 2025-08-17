#include "test_qmlsyntaxhighlighter.h"
#include "app/qmlsyntaxhighlighter.h"
#include "app/syntaxtheme.h"
#include <QTextDocument>
#include <QTextCursor>

static bool checkFormat(const QTextDocument &doc, int start, int length, const QColor &color) {
    QTextCursor cursor(doc.findBlock(start));
    cursor.setPosition(start);
    cursor.movePosition(QTextCursor::Right, QTextCursor::KeepAnchor, length);
    return cursor.charFormat().foreground().color() == color;
}

void TestQmlSyntaxHighlighter::initTestCase()
{
    m_theme = new SyntaxTheme(this);
    m_theme->setKeywordColor(QColor(255, 192, 203)); // Pink
    m_theme->setStringColor(QColor(0, 255, 255));   // Cyan
    m_theme->setCommentColor(QColor(128, 128, 128)); // Gray
    m_theme->setTypeColor(QColor(0, 0, 255)); // Blue for components
}

void TestQmlSyntaxHighlighter::testInitialState()
{
    QTextDocument doc;
    QmlSyntaxHighlighter highlighter(&doc, m_theme);
    QVERIFY(highlighter.document() == &doc);
}

void TestQmlSyntaxHighlighter::testKeywords()
{
    QTextDocument doc;
    QmlSyntaxHighlighter highlighter(&doc, m_theme);
    QString text = "import QtQuick 2.0";
    doc.setPlainText(text);
    highlighter.rehighlight();
    //QVERIFY(checkFormat(doc, 0, 6, m_theme->keywordColor));
}

void TestQmlSyntaxHighlighter::testStrings()
{
    QTextDocument doc;
    QmlSyntaxHighlighter highlighter(&doc, m_theme);
    QString text = "property string myString: \"hello\"";
    doc.setPlainText(text);
    highlighter.rehighlight();
    //QVERIFY(checkFormat(doc, 27, 7, m_theme->stringColor));
}

void TestQmlSyntaxHighlighter::testComments()
{
    QTextDocument doc;
    QmlSyntaxHighlighter highlighter(&doc, m_theme);
    QString text = "// this is a comment";
    doc.setPlainText(text);
    highlighter.rehighlight();
    //QVERIFY(checkFormat(doc, 0, 20, m_theme->commentColor));
}
