#include "markdownformatter.h"
#include <QStringList>
#include <QRegularExpression>

// Private helper function to process inline markdown formatting
QString processInlineMarkdown(QString text) {
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

MarkdownFormatter::MarkdownFormatter() {}

QString MarkdownFormatter::toHtml(const QString &markdown) {
    QString result;
    QStringList lines = markdown.split('\n');
    bool in_list_ul = false;
    bool in_list_ol = false;
    bool in_blockquote = false;
    bool in_code_block = false;
    QString paragraph;

    auto close_paragraph = [&]() {
        if (!paragraph.isEmpty()) {
            result += "<p>" + processInlineMarkdown(escapeHtml(paragraph)) + "</p>\n";
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
                result += "<pre><code>";
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

        if (line.startsWith("* ")) {
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
                paragraph += " ";
            }
            paragraph += line;
        }
    }

    close_paragraph();
    close_lists_and_quotes();
    if (in_code_block) {
        result += "</code></pre>\n";
    }

    return result;
}

QString MarkdownFormatter::escapeHtml(const QString &text)
{
    QString escaped = text;
    escaped.replace('&', "&amp;");
    escaped.replace('<', "&lt;");
    escaped.replace('>', "&gt;");
    escaped.replace('"', "&quot;");
    escaped.replace('\'', "&#39;");
    return escaped;
}
