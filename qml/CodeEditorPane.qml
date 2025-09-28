import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import net.veskuh.pari 1.0

ColumnLayout {
    property alias text: codeEditor.text
    property alias selection: codeEditor.selectedText
    property alias textDocument: codeEditor.textDocument
    property int cursorPosition: 0
    property real scrollY: 0
    property bool dirty: false
    property bool isActivePane: false
    property string filePath: ""

    TextDocumentSearcher {
        id: textDocumentSearcher
    }

    function saveCursorPosition() {
        cursorPosition = codeEditor.cursorPosition;
    }

    function restoreCursorPosition() {
        codeEditor.cursorPosition = cursorPosition;
    }

    function saveScrollPosition() {
        scrollY = codeEditorFlickable.contentY;
    }

    function restoreScrollPosition() {
        codeEditorFlickable.contentY = scrollY;
    }

    function find() {
        findOverlay.open();
    }

    function format() {
        saveScrollPosition();
        if (filePath) {
            if (filePath.endsWith(".qml")) {
                toolManager.indentQmlFile(filePath, codeEditor.text);
            } else if (isCppFile(filePath)) {
                lspClient.format(filePath, codeEditor.text);
            }
        }
    }

    function isCppFile(filePath) {
        return filePath.endsWith(".cpp") || filePath.endsWith(".h") || filePath.endsWith(".cxx") || filePath.endsWith(".hpp") || filePath.endsWith(".cc") || filePath.endsWith(".hh");
    }

    function goToPosition(position) {
        var lineRect = codeEditor.positionToRectangle(position);
        var flickableHeight = codeEditorFlickable.height;
        var contentY = lineRect.y - (flickableHeight / 2) + (lineRect.height / 2);
        codeEditorFlickable.contentY = Math.max(0, Math.min(contentY, codeEditorFlickable.contentHeight - flickableHeight));
    }

    function goToLine(lineNumber) {
        var line = Math.max(0, lineNumber - 1);
        var text = codeEditor.text;
        var lines = text.split('\n');
        if (line >= lines.length) {
            return;
        }
        var position = 0;
        for (var i = 0; i < line; i++) {
            position += lines[i].length + 1; // +1 for the newline character
        }

        codeEditor.cursorPosition = position;
        codeEditor.forceActiveFocus();
        goToPosition(position)
    }

    FindOverlay {
        id: findOverlay
        width: parent.width
        color: appWindow.palette.window
        borderColor: appWindow.palette.windowText
        textColor: appWindow.palette.text
        textBackgroundColor: appWindow.palette.base
        onFindNext: {
            var newPos = codeEditor.text.indexOf(findOverlay.searchText, codeEditor.cursorPosition)

            if (newPos !== -1) {
                codeEditor.cursorPosition = newPos + searchText.length;
                codeEditor.select(newPos, newPos + searchText.length);
                goToPosition(newPos)
            }
            var occurrences = codeEditor.text.split(findOverlay.searchText).length - 1;
            findOverlay.updateResults(occurrences);
        }

        onFindPrevious: {
            var oldPos = codeEditor.cursorPosition;
            var newPos = codeEditor.text.lastIndexOf(findOverlay.searchText, codeEditor.cursorPosition - (searchText.length+1))

            if (codeEditor.cursorPosition === newPos) {
                newPos = codeEditor.text.lastIndexOf(findOverlay.searchText, codeEditor.cursorPosition - (searchText.length+1))
            }

            if (newPos !== -1) {
                codeEditor.cursorPosition = newPos + searchText.length;
                codeEditor.select(newPos, newPos + searchText.length);
                goToPosition(newPos)
            }
            var occurrences = codeEditor.text.split(findOverlay.searchText).length - 1;
            findOverlay.updateResults(occurrences);
        }
        onCloseOverlay: close()
    }

    // ScrollView is necessary for when content exceeds the visible area.
    ScrollView {
        id: codeEditorScrollView
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true // Ensures content doesn't draw outside the ScrollView

        Flickable {
            id: codeEditorFlickable
            clip: true
            contentHeight: codeEditor.contentHeight
            Item {
                width: codeEditorScrollView.width

                Item {

                    width: 25
                    height: codeEditor.height

                    Repeater {
                        id: lineNumberRepeater
                        model: [] // Initially empty

                        delegate: Text {
                            // Position the line number. 'modelData' is the y-coordinate from the array.
                            y: modelData
                            x: 5 // A small horizontal padding from the left edge.

                            // Display the line number (index is 0-based, so we add 1).
                            text: index + 1

                            color: codeEditor.cursorRectangle.y == y ? palette.highlightedText : palette.placeholderText
                            font.pixelSize: codeEditor.font.pixelSize
                            font.family: codeEditor.font.family
                            horizontalAlignment: Text.AlignRight
                            width: 25 // Fixed width to ensure alignment
                        }
                    }
                }

                TextArea {
                    id: codeEditor
                    x: 30
                    width: codeEditorScrollView.width - 50
                    height: contentHeight > codeEditorScrollView.height ? (contentHeight + 20) : codeEditorScrollView.height
                    placeholderText: "✏️ Open a file or start typing..."
                    wrapMode: Text.WordWrap
                    font.family: appSettings.fontFamily
                    font.pointSize: appSettings.fontSize
                    tabStopDistance: 4 * textMetrics.advanceWidth

                    function handleAutoIndent() {
                        if (isIndenting || !codeEditor.activeFocus) {
                            return;
                        }

                        var currentPos = codeEditor.cursorPosition;
                        var text = codeEditor.getText(0, currentPos);
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
                        codeEditor.insert(currentPos, indentation);
                        isIndenting = false;
                    }

                    onTextChanged: {
                        if (codeEditor.activeFocus && codeEditor.length !== previousLength) {
                            // Not just a formatting change
                            dirty = true;
                        }

                        // We are only intrested in new letters being typed
                        if (codeEditor.length !== (previousLength + 1)) {
                            previousLength = codeEditor.length;
                            return;
                        }
                        previousLength = codeEditor.length;

                        aiOutputPane.updateDiff(codeEditor.text);
                        if (filePath && isCppFile(filePath)) {
                            lspClient.documentChanged(filePath, codeEditor.text);
                            var text = codeEditor.getText(0, codeEditor.cursorPosition);
                            if (text.endsWith(".") || text.endsWith("->")) {
                                var textToCursor = codeEditor.getText(0, codeEditor.cursorPosition);
                                var lines = textToCursor.split(/\r?\n/);
                                var line = lines.length - 1;
                                var character = lines[lines.length - 1].length;
                                console.log("Requesting completion at", line, character);
                                lspClient.requestCompletion(filePath, line, character);
                            }
                        }
                        handleAutoIndent();
                    }

                    onContentHeightChanged: {
                        // Array to store the y-coordinates.
                        const coordinates = [];
                        const textContent = codeEditor.text;
                        let searchIndex = 0;
                        let newlineIndex;

                        // First line
                        const rect = codeEditor.positionToRectangle(0);
                        coordinates.push(rect.y);

                        // Loop through the text to find all occurrences of the newline character '\n'.
                        while ((newlineIndex = textContent.indexOf('\n', searchIndex)) !== -1) {
                            // We want the y-coordinate of the character AFTER the newline
                            const nextCharIndex = newlineIndex + 1;

                            if (nextCharIndex < textContent.length) {
                                const rect = codeEditor.positionToRectangle(nextCharIndex);
                                coordinates.push(rect.y);
                            }
                            searchIndex = newlineIndex + 1;
                        }
                        lineNumberRepeater.model = coordinates;
                    }

                    property int savedCursorPosition: 0
                    property int previousLength: 0

                    TextMetrics {
                        id: textMetrics
                        font: codeEditor.font
                    }

                    property bool isIndenting: false
                }
            }
        }
    }

    Connections {
        target: lspClient

        function onFormattingResult(result) {
            codeEditor.text = result;
            restoreCursorPosition();
            restoreScrollPosition();
        }

        function onCompletionItems(items) {
            if (isActivePane) {
                completionPopup.showCompletions(items);
            }
        }
    }

    CompletionPopup {
        id: completionPopup
        width: 200
        height: 300
        y: codeEditor.cursorRectangle.y + codeEditor.cursorRectangle.height
        x: codeEditor.cursorRectangle.x
    }
}
