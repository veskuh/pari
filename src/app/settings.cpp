#include "settings.h"

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
    if (m_availableModels == models)
        return;
    m_availableModels = models;
    emit availableModelsChanged();
}

void Settings::loadSettings()
{
    m_ollamaUrl = m_qsettings.value("ollama/url", "http://localhost:11434").toString();
    m_ollamaModel = m_qsettings.value("ollama/model", "codellama").toString();
    m_fontFamily = m_qsettings.value("editor/fontFamily", "monospace").toString();
    m_fontSize = m_qsettings.value("editor/fontSize", 12).toInt();
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
