#include "test_syntaxtheme.h"
#include "syntaxtheme.h"
#include <QtTest>
#include <QSignalSpy>

void TestSyntaxTheme::testSettersAndSignals()
{
    SyntaxTheme theme;
    
    QSignalSpy keywordSpy(&theme, &SyntaxTheme::keywordColorChanged);
    theme.setKeywordColor(QColor("red"));
    QCOMPARE(theme.keywordColor, QColor("red"));
    QCOMPARE(keywordSpy.count(), 1);
    
    QSignalSpy stringSpy(&theme, &SyntaxTheme::stringColorChanged);
    theme.setStringColor(QColor("green"));
    QCOMPARE(theme.stringColor, QColor("green"));
    QCOMPARE(stringSpy.count(), 1);
    
    QSignalSpy commentSpy(&theme, &SyntaxTheme::commentColorChanged);
    theme.setCommentColor(QColor("blue"));
    QCOMPARE(theme.commentColor, QColor("blue"));
    QCOMPARE(commentSpy.count(), 1);
    
    QSignalSpy typeSpy(&theme, &SyntaxTheme::typeColorChanged);
    theme.setTypeColor(QColor("yellow"));
    QCOMPARE(theme.typeColor, QColor("yellow"));
    QCOMPARE(typeSpy.count(), 1);
    
    QSignalSpy numberSpy(&theme, &SyntaxTheme::numberColorChanged);
    theme.setNumberColor(QColor("cyan"));
    QCOMPARE(theme.numberColor, QColor("cyan"));
    QCOMPARE(numberSpy.count(), 1);
    
    QSignalSpy preprocessorSpy(&theme, &SyntaxTheme::preprocessorColorChanged);
    theme.setPreprocessorColor(QColor("magenta"));
    QCOMPARE(theme.preprocessorColor, QColor("magenta"));
    QCOMPARE(preprocessorSpy.count(), 1);
    
    // Test that setting same color doesn't emit signal
    theme.setKeywordColor(QColor("red"));
    QCOMPARE(keywordSpy.count(), 1);
}
