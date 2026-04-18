import QtQuick
import "../utils/FileUtils.js" as FileUtils

QtObject {
    id: editorLogic
    
    property var editor: null
    property var lspClient: null
    property string filePath: ""
    
    // Configuration
    property bool isIndenting: false
    property int previousLength: 0

    function handleAutoIndent() {
        if (!editor || isIndenting || !editor.activeFocus) {
            return;
        }

        var currentPos = editor.cursorPosition;
        var text = editor.getText(0, currentPos);
        var lines = text.split('\n');
        if (lines.length < 2) {
            return;
        }

        var line = lines[lines.length - 1];
        if (line !== "") {
            return;
        }

        var previousLine = lines[lines.length - 2];
        var indentation = previousLine.match(/^\s*/)[0];
        if (previousLine.trim().endsWith('{')) {
            indentation += "    ";
        }
        if (line.trim().startsWith('}')) {
            indentation = indentation.substring(0, Math.max(0, indentation.length - 4));
        }
        isIndenting = true;
        editor.insert(currentPos, indentation);
        isIndenting = false;
    }

    function handleTextChanged() {
        if (!editor) return;

        // We are only interested in new letters being typed for completions
        if (editor.length !== (previousLength + 1)) {
            previousLength = editor.length;
            return;
        }
        previousLength = editor.length;

        if (filePath && FileUtils.isCppFile(filePath) && lspClient) {
            lspClient.documentChanged(filePath, editor.text);
            var text = editor.getText(0, editor.cursorPosition);
            if (text.endsWith(".") || text.endsWith("->")) {
                var textToCursor = editor.getText(0, editor.cursorPosition);
                var lines = textToCursor.split(/\r?\n/);
                var line = lines.length - 1;
                var character = lines[lines.length - 1].length;
                console.log("Requesting completion at", line, character);
                lspClient.requestCompletion(filePath, line, character);
            }
        }
        handleAutoIndent();
    }
}
