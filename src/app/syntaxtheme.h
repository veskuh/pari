#ifndef SYNTAXTHEME_H
#define SYNTAXTHEME_H

#include <QObject>
#include <QColor>

class SyntaxTheme : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor keywordColor MEMBER keywordColor WRITE setKeywordColor NOTIFY keywordColorChanged)
    Q_PROPERTY(QColor stringColor MEMBER stringColor WRITE setStringColor NOTIFY stringColorChanged)
    Q_PROPERTY(QColor commentColor MEMBER commentColor WRITE setCommentColor NOTIFY commentColorChanged)
    Q_PROPERTY(QColor typeColor MEMBER typeColor WRITE setTypeColor NOTIFY typeColorChanged)
    Q_PROPERTY(QColor numberColor MEMBER numberColor WRITE setNumberColor NOTIFY numberColorChanged)
    Q_PROPERTY(QColor preprocessorColor MEMBER preprocessorColor WRITE setPreprocessorColor NOTIFY preprocessorColorChanged)

public:
    explicit SyntaxTheme(QObject *parent = nullptr);

    QColor keywordColor;
    QColor stringColor;
    QColor commentColor;
    QColor typeColor;
    QColor numberColor;
    QColor preprocessorColor;

    void setKeywordColor(const QColor &color);
    void setStringColor(const QColor &color);
    void setCommentColor(const QColor &color);
    void setTypeColor(const QColor &color);
    void setNumberColor(const QColor &color);
    void setPreprocessorColor(const QColor &color);

signals:
    void keywordColorChanged();
    void stringColorChanged();
    void commentColorChanged();
    void typeColorChanged();
    void numberColorChanged();
    void preprocessorColorChanged();
};

#endif // SYNTAXTHEME_H