#include "settings.h"
#include "syntaxtheme.h"
#include <QDebug>
#include <QTimer>
#include <QPalette>

Settings::Settings(QObject *parent)
    : QObject{parent}
    , m_lightTheme(new SyntaxTheme(this))
    , m_darkTheme(new SyntaxTheme(this))
    , m_qsettings("veskuh.net", "Pari")
{
    loadSettings();
    // Initialize m_systemThemeIsDark based on current system theme
    m_systemThemeIsDark = querySystemTheme();
}

bool Settings::querySystemTheme() const
{
    return m_systemThemeIsDark;
}

QStringList Settings::availableModels() const
{
    return m_availableModels;
}

void Settings::setAvailableModels(const QStringList &models)
{
    qDebug() << models;
    if (m_availableModels == models)
        return;
    m_availableModels = models;
    emit availableModelsChanged();
}

void Settings::loadSettings()
{
    m_ollamaUrl = m_qsettings.value("ollama/url", "http://localhost:11434").toString();
    m_ollamaModel = m_qsettings.value("ollama/model", "gemma3:12b").toString();
    m_fontFamily = m_qsettings.value("editor/fontFamily", "monospace").toString();
    m_fontSize = m_qsettings.value("editor/fontSize", 12).toInt();
    m_recentFolders = m_qsettings.value("recentFolders").toStringList();

    m_lightTheme->keywordColor = m_qsettings.value("theme/light/keywordColor", QColor("#0000FF")).value<QColor>();
    m_lightTheme->stringColor = m_qsettings.value("theme/light/stringColor", QColor("#A31515")).value<QColor>();
    m_lightTheme->commentColor = m_qsettings.value("theme/light/commentColor", QColor("#008000")).value<QColor>();
    m_lightTheme->typeColor = m_qsettings.value("theme/light/typeColor", QColor("#2B91AF")).value<QColor>();
    m_lightTheme->numberColor = m_qsettings.value("theme/light/numberColor", QColor("#FF0000")).value<QColor>();
    m_lightTheme->preprocessorColor = m_qsettings.value("theme/light/preprocessorColor", QColor("#800000")).value<QColor>();

    m_darkTheme->keywordColor = m_qsettings.value("theme/dark/keywordColor", QColor("#569CD6")).value<QColor>();
    m_darkTheme->stringColor = m_qsettings.value("theme/dark/stringColor", QColor("#D69D85")).value<QColor>();
    m_darkTheme->commentColor = m_qsettings.value("theme/dark/commentColor", QColor("#6A9955")).value<QColor>();
    m_darkTheme->typeColor = m_qsettings.value("theme/dark/typeColor", QColor("#4EC9B0")).value<QColor>();
    m_darkTheme->numberColor = m_qsettings.value("theme/dark/numberColor", QColor("#B5CEA8")).value<QColor>();
    m_darkTheme->preprocessorColor = m_qsettings.value("theme/dark/preprocessorColor", QColor("#9B9B9B")).value<QColor>();
}

QString Settings::ollamaUrl() const
{
    return m_ollamaUrl;
}

void Settings::setOllamaUrl(const QString &url)
{
    if (m_ollamaUrl != url) {
        m_ollamaUrl = url;
        m_qsettings.setValue("ollama/url", m_ollamaUrl);
        emit ollamaUrlChanged();
    }
}

QString Settings::ollamaModel() const
{
    return m_ollamaModel;
}

void Settings::setOllamaModel(const QString &model)
{
    if (m_ollamaModel != model) {
        m_ollamaModel = model;
        m_qsettings.setValue("ollama/model", m_ollamaModel);
        emit ollamaModelChanged();
    }
}

QString Settings::fontFamily() const
{
    return m_fontFamily;
}

void Settings::setFontFamily(const QString &family)
{
    if (m_fontFamily != family) {
        m_fontFamily = family;
        m_qsettings.setValue("editor/fontFamily", m_fontFamily);
        emit fontFamilyChanged();
    }
}

int Settings::fontSize() const
{
    return m_fontSize;
}

void Settings::setFontSize(int size)
{
    if (m_fontSize != size) {
        m_fontSize = size;
        m_qsettings.setValue("editor/fontSize", m_fontSize);
        emit fontSizeChanged();
    }
}

QStringList Settings::recentFolders() const
{
    return m_recentFolders;
}

void Settings::addRecentFolder(const QString &folder)
{
    m_recentFolders.removeAll(folder);
    m_recentFolders.prepend(folder);
    if (m_recentFolders.size() > 10)
        m_recentFolders.removeLast();
    setRecentFolders(m_recentFolders);
}

void Settings::clearRecentFolders()
{
    setRecentFolders({});
}

void Settings::setRecentFolders(const QStringList &recentFolders)
{
    m_recentFolders = recentFolders;
    m_qsettings.setValue("recentFolders", m_recentFolders);
    emit recentFoldersChanged();
}

void Settings::saveColors()
{
    m_qsettings.setValue("theme/light/keywordColor", m_lightTheme->keywordColor);
    m_qsettings.setValue("theme/light/stringColor", m_lightTheme->stringColor);
    m_qsettings.setValue("theme/light/commentColor", m_lightTheme->commentColor);
    m_qsettings.setValue("theme/light/typeColor", m_lightTheme->typeColor);
    m_qsettings.setValue("theme/light/numberColor", m_lightTheme->numberColor);
    m_qsettings.setValue("theme/light/preprocessorColor", m_lightTheme->preprocessorColor);

    m_qsettings.setValue("theme/dark/keywordColor", m_darkTheme->keywordColor);
    m_qsettings.setValue("theme/dark/stringColor", m_darkTheme->stringColor);
    m_qsettings.setValue("theme/dark/commentColor", m_darkTheme->commentColor);
    m_qsettings.setValue("theme/dark/typeColor", m_darkTheme->typeColor);
    m_qsettings.setValue("theme/dark/numberColor", m_darkTheme->numberColor);
    m_qsettings.setValue("theme/dark/preprocessorColor", m_darkTheme->preprocessorColor);
}

bool Settings::systemThemeIsDark() const
{
    return m_systemThemeIsDark;
}

void Settings::setSystemTheme(bool isDark)
{
    m_systemThemeIsDark = isDark;
}

SyntaxTheme* Settings::lightTheme() const
{
    return m_lightTheme;
}

SyntaxTheme* Settings::darkTheme() const
{
    return m_darkTheme;
}
