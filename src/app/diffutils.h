#ifndef DIFFUTILS_H
#define DIFFUTILS_H

#include <QObject>
#include <QString>

class DiffUtils : public QObject
{
    Q_OBJECT
public:
    explicit DiffUtils(QObject *parent = nullptr);

    Q_INVOKABLE QString createDiff(const QString &text1, const QString &text2) const;
};

#endif // DIFFUTILS_H
