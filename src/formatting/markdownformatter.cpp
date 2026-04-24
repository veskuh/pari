#include "markdownformatter.h"
#include <QStringList>
#include <QRegularExpression>

MarkdownFormatter::MarkdownFormatter(QObject *parent) : QObject(parent) {}

QString MarkdownFormatter::processInlineMarkdown(QString text) const {
    // code
    text.replace(QRegularExpression("`(.*?)`"), "<code>\\1</code>");
    // Bold
    text.replace(QRegularExpression("\\*\\*(.*?)\\*\\*"), "<b>\\1</b>");
    // Italics
    text.replace(QRegularExpression("\\*(.*?)\\*"), "<i>\\1</i>");
    // Strikethrough
    text.replace(QRegularExpression("~~(.*?)~~"), "<s>\\1</s>");
    // Links
    text.replace(QRegularExpression("\\[([^\\]]+)\\]\\(([^\\)]+)\\)"), "<a href=\"\\2\">\\1</a>");
    return text;
}

QString MarkdownFormatter::toHtml(const QString &markdown) const {
    if (markdown.isEmpty()) return "";

    QString result;
    QStringList lines = markdown.split('\n');
    bool in_list_ul = false;
    bool in_list_ol = false;
    bool in_blockquote = false;
    bool in_code_block = false;
    QString paragraph;

    auto close_paragraph = [&]() {
        if (!paragraph.isEmpty()) {
            QString escaped = escapeHtml(paragraph);
            // Convert internal newlines to HTML breaks
            escaped.replace('\n', "<br>\n");
            result += "<p>" + processInlineMarkdown(escaped) + "</p>\n";
            paragraph.clear();
        }
    };

    auto close_lists_and_quotes = [&]() {
        if (in_list_ul) { result += "</ul>\n"; in_list_ul = false; }
        if (in_list_ol) { result += "</ol>\n"; in_list_ol = false; }
        if (in_blockquote) { result += "</blockquote>\n"; in_blockquote = false; }
    };

    for (const QString &line : lines) {
        if (line.startsWith("```")) {
            close_paragraph();
            close_lists_and_quotes();
            if (in_code_block) {
                result += "</code></pre>\n";
            } else {
                result += "<pre style=\"background-color: #f5f5f5; padding: 10px; border-radius: 4px;\"><code>";
            }
            in_code_block = !in_code_block;
            continue;
        }

        if (in_code_block) {
            result += escapeHtml(line) + "\n";
            continue;
        }

        if (line.trimmed().isEmpty()) {
            close_paragraph();
            close_lists_and_quotes();
            continue;
        }

        if (line.startsWith("* ") || line.startsWith("- ")) {
            close_paragraph();
            if (in_list_ol) { result += "</ol>\n"; in_list_ol = false; }
            if (in_blockquote) { result += "</blockquote>\n"; in_blockquote = false; }
            if (!in_list_ul) {
                result += "<ul>\n";
                in_list_ul = true;
            }
            result += "<li>" + processInlineMarkdown(escapeHtml(line.mid(2))) + "</li>\n";
        } else if (QRegularExpression("^\\d+\\. ").match(line).hasMatch()) {
            close_paragraph();
            if (in_list_ul) { result += "</ul>\n"; in_list_ul = false; }
            if (in_blockquote) { result += "</blockquote>\n"; in_blockquote = false; }
            if (!in_list_ol) {
                result += "<ol>\n";
                in_list_ol = true;
            }
            result += "<li>" + processInlineMarkdown(escapeHtml(line.mid(line.indexOf(". ") + 2))) + "</li>\n";
        } else if (line.startsWith("> ")) {
            close_paragraph();
            if (in_list_ul) { result += "</ul>\n"; in_list_ul = false; }
            if (in_list_ol) { result += "</ol>\n"; in_list_ol = false; }
            if (!in_blockquote) {
                result += "<blockquote>";
                in_blockquote = true;
            }
            result += processInlineMarkdown(escapeHtml(line.mid(2))) + "<br>";
        } else {
            close_lists_and_quotes();
            if (!paragraph.isEmpty()) {
                paragraph += "\n";
            }
            paragraph += line;
        }
    }

    // Handle any remaining open tags for streaming support
    if (!paragraph.isEmpty()) {
        QString escaped = escapeHtml(paragraph);
        escaped.replace('\n', "<br>\n");
        result += "<p>" + processInlineMarkdown(escaped) + "</p>\n";
    }
    if (in_list_ul) result += "</ul>\n";
    if (in_list_ol) result += "</ol>\n";
    if (in_blockquote) result += "</blockquote>\n";
    if (in_code_block) result += "</code></pre>\n";

    return result;
}

QString MarkdownFormatter::escapeHtml(const QString &text) const
{
    QString escaped = text;
    escaped.replace('&', "&amp;");
    escaped.replace('<', "&lt;");
    escaped.replace('>', "&gt;");
    escaped.replace('"', "&quot;");
    escaped.replace('\'', "&#39;");
    return escaped;
}
