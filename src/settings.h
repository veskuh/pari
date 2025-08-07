#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QString>
#include <QFont>
#include <QSettings>

class Settings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString ollamaUrl READ ollamaUrl WRITE setOllamaUrl NOTIFY ollamaUrlChanged)
    Q_PROPERTY(QString ollamaModel READ ollamaModel WRITE setOllamaModel NOTIFY ollamaModelChanged)
    Q_PROPERTY(QString fontFamily READ fontFamily WRITE setFontFamily NOTIFY fontFamilyChanged)
    Q_PROPERTY(int fontSize READ fontSize WRITE setFontSize NOTIFY fontSizeChanged)

public:
    explicit Settings(QObject *parent = nullptr);

    QString ollamaUrl() const;
    void setOllamaUrl(const QString &url);

    QString ollamaModel() const;
    void setOllamaModel(const QString &model);

    QString fontFamily() const;
    void setFontFamily(const QString &family);

    int fontSize() const;
    void setFontSize(int size);

signals:
    void ollamaUrlChanged();
    void ollamaModelChanged();
    void fontFamilyChanged();
    void fontSizeChanged();

private:
    void loadSettings();

    QString m_ollamaUrl;
    QString m_ollamaModel;
    QString m_fontFamily;
    int m_fontSize;

    QSettings m_qsettings;
};

#endif // SETTINGS_H
