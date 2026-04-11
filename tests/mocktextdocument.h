#ifndef MOCKTEXTDOCUMENT_H
#define MOCKTEXTDOCUMENT_H

#include <QObject>
#include <QTextDocument>

class MockTextDocument : public QObject
{
    Q_OBJECT
public:
    explicit MockTextDocument(QTextDocument *doc, QObject *parent = nullptr) 
        : QObject(parent), m_doc(doc) {}
    
    Q_INVOKABLE QTextDocument* textDocument() const { return m_doc; }

private:
    QTextDocument *m_doc;
};

#endif // MOCKTEXTDOCUMENT_H
