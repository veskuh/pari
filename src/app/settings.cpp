#include "settings.h"
#include <QDebug>
#include <QDir>

Settings::Settings(QObject *parent)
    : QObject{parent},
      m_qsettings("veskuh.net", "Pari")
{
    loadSettings();
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
    m_recentFolders = m_qsettings.value("folders/recent", QStringList()).toStringList();
}

QStringList Settings::recentFolders() const
{
    return m_recentFolders;
}

void Settings::setRecentFolders(const QStringList &folders)
{
    if (m_recentFolders == folders)
        return;

    m_recentFolders = folders;
    m_qsettings.setValue("folders/recent", m_recentFolders);
    emit recentFoldersChanged();
}

void Settings::addRecentFolder(const QString &folder)
{
    if (!QDir(folder).exists()) {
        m_recentFolders.removeAll(folder);
        setRecentFolders(m_recentFolders);
        return;
    }

    m_recentFolders.removeAll(folder);
    m_recentFolders.prepend(folder);

    if (m_recentFolders.size() > 10)
        m_recentFolders.removeLast();

    setRecentFolders(m_recentFolders);
}

void Settings::clearRecentFolders()
{
    setRecentFolders(QStringList());
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
