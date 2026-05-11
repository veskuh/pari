#ifndef TEST_SYNTAXHIGHLIGHTERPROVIDER_H
#define TEST_SYNTAXHIGHLIGHTERPROVIDER_H

#include <QtTest>
#include "syntaxhighlighterprovider.h"
#include "settings.h"

class TestSyntaxHighlighterProvider : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void testSupportedExtensions();
    void testSupportedFileNames();
    void testAttachHighlighter();

private:
    Settings *m_settings;
    SyntaxHighlighterProvider *m_provider;
};

#endif // TEST_SYNTAXHIGHLIGHTERPROVIDER_H
