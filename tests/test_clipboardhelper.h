#ifndef TEST_CLIPBOARDHELPER_H
#define TEST_CLIPBOARDHELPER_H

#include <QObject>
#include <QtTest>
#include <QClipboard>
#include <QGuiApplication>
#include "clipboardhelper.h"

class TestClipboardHelper : public QObject
{
    Q_OBJECT

private slots:
    void testSetText() {
        ClipboardHelper helper;
        QString testText = "Hello Clipboard";
        helper.setText(testText);
        
        // Verify via QClipboard
        QClipboard *clipboard = QGuiApplication::clipboard();
        if (clipboard) {
            QCOMPARE(clipboard->text(), testText);
        }
    }
};

#endif // TEST_CLIPBOARDHELPER_H
