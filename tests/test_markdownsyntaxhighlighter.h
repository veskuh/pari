#ifndef TEST_MARKDOWNSYNTAXHIGHLIGHTER_H
#define TEST_MARKDOWNSYNTAXHIGHLIGHTER_H

#include <QObject>

class TestMarkdownSyntaxHighlighter : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();

    void testHighlight_Headers();
    void testHighlight_Bold();
    void testHighlight_Italic();
    void testHighlight_Links();
    void testHighlight_Images();
    void testHighlight_Blockquotes();
    void testHighlight_InlineCode();
    void testHighlight_CodeBlocks();
    void testHighlight_Comments();

private:
    // Test data and helper methods can be added here
};

#endif // TEST_MARKDOWNSYNTAXHIGHLIGHTER_H
