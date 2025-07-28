#ifndef LLM_H
#define LLM_H

#include <QObject>

class Llm : public QObject
{
    Q_OBJECT
public:
    explicit Llm(QObject *parent = nullptr);

signals:

};

#endif // LLM_H
