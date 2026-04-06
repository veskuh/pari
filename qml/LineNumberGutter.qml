import QtQuick
import QtQuick.Controls

Item {
    id: gutter
    width: 35
    
    property int currentLineIndex: -1
    property bool isDark: false
    property font editorFont
    property alias lineCoordinates: lineNumberRepeater.model

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
            y: modelData
            x: 0
            width: gutter.width - 5
            text: index + 1
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
        let newlineIndex;

        // First line
        const rect = editor.positionToRectangle(0);
        coordinates.push(rect.y);

        // Subsequent lines
        while ((newlineIndex = textContent.indexOf('\n', searchIndex)) !== -1) {
            const nextCharIndex = newlineIndex + 1;
            const lineRect = editor.positionToRectangle(nextCharIndex);
            coordinates.push(lineRect.y);
            searchIndex = nextCharIndex;
        }
        return coordinates;
    }

    function refresh(editor) {
        lineCoordinates = calculateLineCoordinates(editor);
    }
}
