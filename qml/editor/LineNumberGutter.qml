import QtQuick
import QtQuick.Controls

Item {
    id: gutter
    width: 35
    
    property int currentLineIndex: -1
    property bool isDark: false
    property font editorFont
    property alias lineCoordinates: lineNumberRepeater.model
    
    // Reference to SearchManager for filtered line numbers
    property var searchManager: null

    // Background (Subtle Metallic)
    Rectangle {
        anchors.fill: parent
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

    // Line Number Repeater
    Repeater {
        id: lineNumberRepeater
        model: []

        delegate: Text {
            y: modelData.y
            x: 0
            width: gutter.width - 5
            text: modelData.number // Shows the mapped document line number
            color: gutter.currentLineIndex === index ? (isDark ? "#4aa9ff" : "#0051a6") : (isDark ? "#555555" : "#888888")
            font.pixelSize: gutter.editorFont.pixelSize * 0.9
            font.family: gutter.editorFont.family
            font.bold: gutter.currentLineIndex === index
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignTop
        }
    }

    function calculateLineCoordinates(editor) {
        if (!editor) return [];
        
        const coordinates = [];
        const textContent = editor.text;
        let searchIndex = 0;
        let lineIdx = 0;
        
        const isFiltered = !!(searchManager && searchManager.filterActive && searchManager.filteredLineNumbers && searchManager.filteredLineNumbers.length > 0);
        const lineNums = isFiltered ? searchManager.filteredLineNumbers : [];

        function getLineNumber(idx) {
            if (isFiltered && idx < lineNums.length) {
                return lineNums[idx];
            }
            return idx + 1;
        }

        let lastY = -1;

        // First line
        const rect0 = editor.positionToRectangle(0);
        if (rect0.height > 0) {
            var num0 = getLineNumber(lineIdx);
            coordinates.push({y: rect0.y, number: num0});
            lastY = rect0.y;
            lineIdx++;
        }

        let newlineIndex;
        while ((newlineIndex = textContent.indexOf('\n', searchIndex)) !== -1) {
            const nextCharIndex = newlineIndex + 1;
            const lineRect = editor.positionToRectangle(nextCharIndex);
            
            if (lineRect.y !== lastY) {
                var num = getLineNumber(lineIdx);
                coordinates.push({y: lineRect.y, number: num});
                lastY = lineRect.y;
            }
            lineIdx++;
            searchIndex = nextCharIndex;
        }
        return coordinates;
    }

    function refresh(editor) {
        lineCoordinates = calculateLineCoordinates(editor);
    }
}
