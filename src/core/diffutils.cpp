#include "diffutils.h"
#include <QStringList>
#include <QVector>
#include <algorithm>

// Using a standard dynamic programming approach to find the Longest Common Subsequence (LCS).
QVector<QString> lcs(const QStringList &a, const QStringList &b) {
    QVector<QVector<int>> lengths(a.size() + 1, QVector<int>(b.size() + 1, 0));

    // build the lengths table
    for (int i = 0; i < a.size(); i++) {
        for (int j = 0; j < b.size(); j++) {
            if (a[i] == b[j]) {
                lengths[i + 1][j + 1] = lengths[i][j] + 1;
            } else {
                lengths[i + 1][j + 1] = std::max(lengths[i + 1][j], lengths[i][j + 1]);
            }
        }
    }

    // read the LCS from the lengths table
    QVector<QString> result;
    for (int x = a.size(), y = b.size(); x != 0 && y != 0; ) {
        if (lengths[x][y] == lengths[x - 1][y]) {
            x--;
        } else if (lengths[x][y] == lengths[x][y - 1]) {
            y--;
        } else {
            result.prepend(a[x - 1]);
            x--;
            y--;
        }
    }
    return result;
}

DiffUtils::DiffUtils(QObject *parent) : QObject(parent) {}

QString DiffUtils::createDiff(const QString &text1, const QString &text2) const {
    QStringList lines1 = text1.split('\n');
    if (text1.isEmpty()) lines1.clear();

    QStringList lines2 = text2.split('\n');
    if (text2.isEmpty()) lines2.clear();

    QVector<QString> common = lcs(lines1, lines2);
    QStringList result;
    int i = 0, j = 0, k = 0;

    while (k < common.size()) {
        // Deleted lines
        while (i < lines1.size() && lines1[i] != common[k]) {
            result.append(QString("<span style=\"color: red;\">- %1</span><br>").arg(lines1[i++].toHtmlEscaped()));
        }
        // Added lines
        while (j < lines2.size() && lines2[j] != common[k]) {
            result.append(QString("<span style=\"color: green;\">+ %1</span><br>").arg(lines2[j++].toHtmlEscaped()));
        }
        // Common line
        if (i < lines1.size() && j < lines2.size()) {
            result.append(QString("  %1<br>").arg(common[k].toHtmlEscaped()));
            i++; j++; k++;
        }
    }

    // Remaining deleted lines
    while (i < lines1.size()) {
        result.append(QString("<span style=\"color: red;\">- %1</span>").arg(lines1[i++].toHtmlEscaped()));
    }
    // Remaining added lines
    while (j < lines2.size()) {
        result.append(QString("<span style=\"color: green;\">+ %1</span>").arg(lines2[j++].toHtmlEscaped()));
    }

    return result.join('\n');
}
