#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QString>
#include <QFont>
#include <QSettings>
#include <QColor>
#include <QCryptographicHash>

#include "syntaxtheme.h"

class Settings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString ollamaUrl READ ollamaUrl WRITE setOllamaUrl NOTIFY ollamaUrlChanged)
    Q_PROPERTY(QString ollamaModel READ ollamaModel WRITE setOllamaModel NOTIFY ollamaModelChanged)
    Q_PROPERTY(QString fontFamily READ fontFamily WRITE setFontFamily NOTIFY fontFamilyChanged)
    Q_PROPERTY(int fontSize READ fontSize WRITE setFontSize NOTIFY fontSizeChanged)
    Q_PROPERTY(QStringList availableModels READ availableModels WRITE setAvailableModels NOTIFY availableModelsChanged)
    Q_PROPERTY(QStringList recentFolders READ recentFolders WRITE setRecentFolders NOTIFY recentFoldersChanged)
    Q_PROPERTY(bool systemThemeIsDark READ systemThemeIsDark NOTIFY systemThemeIsDarkChanged)
    Q_PROPERTY(SyntaxTheme* lightTheme READ lightTheme NOTIFY lightThemeChanged)
    Q_PROPERTY(SyntaxTheme* darkTheme READ darkTheme NOTIFY darkThemeChanged)

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

    QStringList recentFolders() const;
    Q_INVOKABLE void addRecentFolder(const QString &folder);
    Q_INVOKABLE void clearRecentFolders();
    Q_INVOKABLE void saveColors();

    Q_INVOKABLE QString getBuildCommand(const QString &projectPath);
    Q_INVOKABLE QString getRunCommand(const QString &projectPath);
    Q_INVOKABLE QString getCleanCommand(const QString &projectPath);
    Q_INVOKABLE void setBuildCommands(const QString &projectPath, const QString &buildCommand, const QString &runCommand, const QString &cleanCommand);

    bool systemThemeIsDark() const;
    void setSystemTheme(bool isDark);

    SyntaxTheme* lightTheme() const;
    SyntaxTheme* darkTheme() const;

signals:
    void ollamaUrlChanged();
    void ollamaModelChanged();
    void fontFamilyChanged();
    void fontSizeChanged();
    void availableModelsChanged();
    void recentFoldersChanged();
    void systemThemeIsDarkChanged();
    void lightThemeChanged();
    void darkThemeChanged();

private:
    void loadSettings();
    void setRecentFolders(const QStringList &recentFolders);
    bool m_systemThemeIsDark;
    bool querySystemTheme() const;

    QString m_ollamaUrl;
    QString m_ollamaModel;
    QString m_fontFamily;
    int m_fontSize;
    QStringList m_availableModels;
    QStringList m_recentFolders;
    SyntaxTheme *m_lightTheme;
    SyntaxTheme *m_darkTheme;

    QSettings m_qsettings;
};

#endif // SETTINGS_H
