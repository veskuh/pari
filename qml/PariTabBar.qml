// CustomTabBar.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root

    // --- PROPERTIES ---
    property int currentIndex: 0
    property var model: ["Tab 1", "Tab 2", "Tab 3"]
    property int indicatorHeight: 3
    property double activeHeaderX : currentIndex * activeHeaderWidth
    property double activeHeaderWidth : 0.0

    // Signal emitted when a tab is clicked
    signal tabClicked(int index)

    SystemPalette {
        id: palette
    }

    // Automatically use the system's window color for the background
    color: "transparent"
    height: parent.height



    // The sliding background "pill" for the active tab.
    // It sits behind the text (z: 0).
    Rectangle {
        id: activeTabBackground

        // Use a semi-transparent version of the system's highlight/accent color
        color: Qt.rgba(palette.highlight.r, palette.highlight.g, palette.highlight.b, 0.2)
        radius: 8 // Rounded corners

        // Sizing and positioning logic

        height: root.height * 0.85
        anchors.bottom: parent.bottom
        width: root.activeHeaderWidth > 10 ? root.activeHeaderWidth - 10 : 0
        x: root.activeHeaderX + 5
        z: 0

        gradient: Gradient {
             orientation: Gradient.Vertical

             GradientStop {
                 position: 0.0
                 // End with a slightly lighter, transparent version of the highlight color
                 color: Qt.rgba(Qt.lighter(palette.highlight, 1.1).r, Qt.lighter(palette.highlight, 1.1).g, Qt.lighter(palette.highlight, 1.1).b, 0.25)
            }
             GradientStop {
                 position: 1.0
                 color: Qt.rgba(Qt.darker(palette.highlight, 1.1).r, Qt.darker(palette.highlight, 1.1).g, Qt.darker(palette.highlight, 1.1).b, 0.2)

             }
         }


        // Animation behaviors
        Behavior on x { SmoothedAnimation { duration: 250; easing.type: Easing.InOutQuad } }
        Behavior on width { SmoothedAnimation { duration: 250; easing.type: Easing.InOutQuad } }
        Behavior on color { ColorAnimation { duration: 200 } }
    }


    RowLayout {
        id: tabLayout
        anchors.fill: parent
        spacing: 0
        z: 1 // Ensure text is drawn on top of the pill background

        Repeater {
            id: repeater
            model: root.model

            delegate: Item {
                id: tabHeader
                Layout.fillWidth: true
                Layout.fillHeight: true

                Image {
                    source: {
                        if (!modelData || !modelData.fileName || modelData.fileName === null)
                            "qrc:/assets/file.png";
                        else if (modelData.fileName.endsWith(".cpp") || modelData.fileName.endsWith(".h"))
                            "qrc:/assets/cpp.png";
                        else if (modelData.fileName.endsWith(".png"))
                            "qrc:/assets/png.png";
                        else if (modelData.fileName.endsWith(".qml"))
                            "qrc:/assets/qml.png";
                        else if (modelData.fileName.endsWith(".md"))
                            "qrc:/assets/md.png";
                        else if (modelData.fileName.endsWith(".txt"))
                            "qrc:/assets/txt.png";
                        else
                            "qrc:/assets/file.png";
                    }
                    sourceSize.height: 24
                    anchors.right: label.left
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                }


                Label {
                    id: label
                    text: modelData.isDirty? modelData.fileName +  "- ✏️ Edited" : modelData.fileName
                    anchors.centerIn: parent
                    font.bold: root.currentIndex === index
                    // Active text uses the system highlight color, inactive uses standard text color
                    color: palette.text
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.currentIndex = index;
                        root.tabClicked(index);
                    }
                }

                onWidthChanged: {
                    if (root.currentIndex === index) {
                        root.activeHeaderWidth = width
                    }
                }
            }
        }
    }

    // The bottom indicator line
    Rectangle {
        id: indicator

        // Use the system's highlight/accent color
        color: palette.highlight
        height: root.indicatorHeight
        anchors.bottom: parent.bottom


        // Positioning logic
        width: activeHeaderWidth
        x: activeHeaderX
        z: 1

        // Animation behaviors
        Behavior on x { SmoothedAnimation { duration: 250; easing.type: Easing.InOutQuad } }
        Behavior on width { SmoothedAnimation { duration: 250; easing.type: Easing.InOutQuad } }
        Behavior on color { ColorAnimation { duration: 200 } }
    }
}
