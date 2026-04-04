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

    // Theme helper
    readonly property bool isDark: appSettings.systemThemeIsDark

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

    function refreshLineNumbers() {
        const coordinates = [];
        const textContent = codeEditor.text;
        let searchIndex = 0;
        let newlineIndex;

        const rect = codeEditor.positionToRectangle(0);
        coordinates.push(rect.y);

        while ((newlineIndex = textContent.indexOf('\n', searchIndex)) !== -1) {
            const nextCharIndex = newlineIndex + 1;
            const lineRect = codeEditor.positionToRectangle(nextCharIndex);
            coordinates.push(lineRect.y);
            searchIndex = nextCharIndex;
        }
        lineNumberRepeater.model = coordinates;
    }

    FindOverlay {
        id: findOverlay
        z: 10
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

    // Recessed 'Paper' Well
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: 4
        radius: 2
        
        // Background: Transitions to creamy (light) or navy (dark) finish when dirty
        color: {
            if (dirty) return isDark ? "#1e2538" : "#fffdf0";
            return isDark ? "#1a1a1a" : "#ffffff";
        }
        
        Behavior on color { ColorAnimation { duration: 300 } }

        // Outer "bevel" to simulate recession into the machine
        border.color: isDark ? "#121212" : "#bcbcbc"
        border.width: 1

        // Inset shadow effect
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            color: "transparent"
            border.color: isDark ? "#000000" : "black"
            opacity: isDark ? 0.2 : 0.05
            radius: 2
        }

        ScrollView {
            id: codeEditorScrollView
            anchors.fill: parent
            anchors.margins: 1
            clip: true

            Flickable {
                id: codeEditorFlickable
                clip: true
                // Use implicitHeight of the TextArea plus some bottom buffer
                contentHeight: Math.max(codeEditor.implicitHeight + 100, codeEditorScrollView.height)

                // Line Number Column Background (Subtle Metallic)
                Rectangle {
                    width: 35
                    height: parent.contentHeight
                    z: 1
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: isDark ? "#2d2d2d" : "#f0f0f0" }
                        GradientStop { position: 1.0; color: isDark ? "#252525" : "#e8e8e8" }
                    }
                    
                    Rectangle {
                        anchors.right: parent.right
                        width: 1
                        height: parent.height
                        color: isDark ? "#121212" : "#d0d0d0"
                    }
                }

                // Line Number Container
                Item {
                    width: 35
                    height: codeEditor.height
                    z: 2

                    Repeater {
                        id: lineNumberRepeater
                        model: []

                        delegate: Text {
                            y: modelData
                            x: 0
                            width: 30
                            text: index + 1
                            color: codeEditor.currentLineIndex === index ? (isDark ? "#4aa9ff" : "#0051a6") : (isDark ? "#555555" : "#888888")
                            font.pixelSize: codeEditor.font.pixelSize * 0.9
                            font.family: "Menlo"
                            font.bold: codeEditor.currentLineIndex === index
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignTop
                        }
                    }
                }

                TextArea {
                    id: codeEditor
                    x: 40
                    width: codeEditorScrollView.width - 50
                    // Set height to implicitHeight to let the Flickable handle scrolling
                    height: implicitHeight
                    placeholderText: "✏️ Open a file or start typing..."
                    wrapMode: Text.WordWrap
                    font.family: appSettings.fontFamily
                    font.pointSize: appSettings.fontSize
                    tabStopDistance: 4 * textMetrics.advanceWidth
                    color: isDark ? "#d0d0d0" : "#1a1c1c"
                    selectionColor: isDark ? "#00458d" : "#0051a6"
                    selectedTextColor: "#ffffff"
                    topPadding: 10
                    bottomPadding: 50 // Large buffer at the bottom
                    leftPadding: 10
                    rightPadding: 10
                    background: null

                    property int savedCursorPosition: 0
                    property int previousLength: 0
                    property bool isIndenting: false
                    
                    // Logic to find current line index based on cursor position
                    property int currentLineIndex: {
                        var textToCursor = text.substring(0, cursorPosition);
                        return textToCursor.split('\n').length - 1;
                    }

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

                        // We are only interested in new letters being typed
                        if (codeEditor.length !== (previousLength + 1)) {
                            previousLength = codeEditor.length;
                            refreshLineNumbers();
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
                        refreshLineNumbers();
                    }

                    onContentHeightChanged: {
                        refreshLineNumbers();
                    }
                    
                    Component.onCompleted: {
                        refreshLineNumbers();
                    }
                }
            }
        }
    }

    TextMetrics {
        id: textMetrics
        font: codeEditor.font
    }

    Connections {
        target: lspClient

        function onFormattingResult(result) {
            codeEditor.text = result;
            restoreCursorPosition();
            restoreScrollPosition();
            refreshLineNumbers();
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
