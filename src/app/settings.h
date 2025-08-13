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
    Q_PROPERTY(QStringList availableModels READ availableModels WRITE setAvailableModels NOTIFY availableModelsChanged)
    Q_PROPERTY(QStringList recentFiles READ recentFiles WRITE setRecentFiles NOTIFY recentFilesChanged)

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

    QStringList availableModels() const;
    void setAvailableModels(const QStringList &models);

    QStringList recentFiles() const;
    void setRecentFiles(const QStringList &files);

    Q_INVOKABLE void addRecentFile(const QString &file);
    Q_INVOKABLE void clearRecentFiles();

signals:
    void ollamaUrlChanged();
    void ollamaModelChanged();
    void fontFamilyChanged();
    void fontSizeChanged();
    void availableModelsChanged();
    void recentFilesChanged();

private:
    void loadSettings();

    QString m_ollamaUrl;
    QString m_ollamaModel;
    QString m_fontFamily;
    int m_fontSize;
    QStringList m_availableModels;
    QStringList m_recentFiles;

    QSettings m_qsettings;
};

#endif // SETTINGS_H
