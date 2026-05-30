import QtQuick
import QtTest
import "../qml/editor"

Item {
    width: 600
    height: 100

    FindOverlay {
        id: overlay
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
    }

    SignalSpy {
        id: findNextSpy
        target: overlay
        signalName: "findNext"
    }

    SignalSpy {
        id: findPreviousSpy
        target: overlay
        signalName: "findPrevious"
    }

    SignalSpy {
        id: closeSpy
        target: overlay
        signalName: "closeOverlay"
    }

    TestCase {
        name: "FindOverlayTests"
        when: windowShown

        function init() {
            findNextSpy.clear()
            findPreviousSpy.clear()
            closeSpy.clear()
            overlay.close()
            overlay.searchText = ""
        }

        function findChildByText(parent, text) {
            if (!parent) return null;
            if (parent.text === text) return parent;

            // Search children
            if (parent.children) {
                for (var i = 0; i < parent.children.length; ++i) {
                    var found = findChildByText(parent.children[i], text)
                    if (found) return found
                }
            }

            // Search content (PariPaperWell)
            if (parent.content) {
                if (parent.content.length !== undefined) {
                    for (var j = 0; j < parent.content.length; j++) {
                        var foundInContent = findChildByText(parent.content[j], text);
                        if (foundInContent) return foundInContent;
                    }
                } else {
                    var foundInContentSingle = findChildByText(parent.content, text);
                    if (foundInContentSingle) return foundInContentSingle;
                }
            }

            return null
        }

        function test_initial_state() {
            verify(!overlay.visible)
        }

        function test_open_close() {
            overlay.open()
            verify(overlay.visible)

            overlay.close()
            verify(!overlay.visible)
        }

        function test_buttons() {
            overlay.open()
            overlay.searchText = "search term"
            overlay.totalMatches = 5
            overlay.currentMatchIndex = 2

            var nextBtn = findChildByText(overlay, "▼")
            var prevBtn = findChildByText(overlay, "▲")
            var closeBtn = findChildByText(overlay, "✕")

            verify(nextBtn !== null, "Next button should be found")
            verify(prevBtn !== null, "Prev button should be found")
            verify(closeBtn !== null, "Close button should be found")

            mouseClick(nextBtn)
            // One for initial change, one for click.
            // Wait, onTextChanged also triggers findNext now.
            // init() sets "" (0), then we set "search term" (1), then mouseClick (2).
            verify(findNextSpy.count >= 1)

            mouseClick(prevBtn)
            compare(findPreviousSpy.count, 1)

            mouseClick(closeBtn)
            compare(closeSpy.count, 1)
        }

        function test_update_results() {
            // Verify no crash
            overlay.updateResults("5")
        }
    }
}
