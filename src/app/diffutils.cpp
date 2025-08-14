#include "diffutils.h"
#include <QStringList>

DiffUtils::DiffUtils(QObject *parent) : QObject(parent)
{
}

QString DiffUtils::createDiff(const QString &text1, const QString &text2) const
{
    if (text1.isEmpty() && text2.isEmpty()) {
        return "";
    }

    QStringList lines1 = text1.split('\n');
    if (text1.isEmpty()) {
        lines1.clear();
    }

    QStringList lines2 = text2.split('\n');
    if (text2.isEmpty()) {
        lines2.clear();
    }

    QStringList diffResult;

    int prefix = 0;
    while (prefix < lines1.size() && prefix < lines2.size() && lines1[prefix] == lines2[prefix]) {
        prefix++;
    }

    int suffix = 0;
    while (suffix + prefix < lines1.size() && suffix + prefix < lines2.size() && lines1[lines1.size() - 1 - suffix] == lines2[lines2.size() - 1 - suffix]) {
        suffix++;
    }

    for (int i = 0; i < prefix; ++i) {
        diffResult.append("  " + lines1[i]);
    }

    for (int i = prefix; i < lines1.size() - suffix; ++i) {
        diffResult.append("- " + lines1[i]);
    }

    for (int i = prefix; i < lines2.size() - suffix; ++i) {
        diffResult.append("+ " + lines2[i]);
    }

    for (int i = lines1.size() - suffix; i < lines1.size(); ++i) {
        diffResult.append("  " + lines1[i]);
    }

    return diffResult.join('\n');
}
