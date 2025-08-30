#include "syntaxtheme.h"

SyntaxTheme::SyntaxTheme(QObject *parent)
    : QObject{parent}
{
    keywordColor = QColor(Qt::transparent);
    stringColor = QColor(Qt::transparent);
    commentColor = QColor(Qt::transparent);
    typeColor = QColor(Qt::transparent);
    numberColor = QColor(Qt::transparent);
    preprocessorColor = QColor(Qt::transparent);
}

void SyntaxTheme::setKeywordColor(const QColor &color)
{
    if (keywordColor != color) {
        keywordColor = color;
        emit keywordColorChanged();
    }
}

void SyntaxTheme::setStringColor(const QColor &color)
{
    if (stringColor != color) {
        stringColor = color;
        emit stringColorChanged();
    }
}

void SyntaxTheme::setCommentColor(const QColor &color)
{
    if (commentColor != color) {
        commentColor = color;
        emit commentColorChanged();
    }
}

void SyntaxTheme::setTypeColor(const QColor &color)
{
    if (typeColor != color) {
        typeColor = color;
        emit typeColorChanged();
    }
}

void SyntaxTheme::setNumberColor(const QColor &color)
{
    if (numberColor != color) {
        numberColor = color;
        emit numberColorChanged();
    }
}

void SyntaxTheme::setPreprocessorColor(const QColor &color)
{
    if (preprocessorColor != color) {
        preprocessorColor = color;
        emit preprocessorColorChanged();
    }
}
