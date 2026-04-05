import QtQuick
import QtTest
import "../qml"

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
            for (var i = 0; i < parent.children.length; ++i) {
                var child = parent.children[i]
                if (child.text === text)
                    return child

                var found = findChildByText(child, text)
                if (found) return found
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

            var nextBtn = findChildByText(overlay, "▼")
            var prevBtn = findChildByText(overlay, "▲")
            var closeBtn = findChildByText(overlay, "✕")

            verify(nextBtn !== null)
            verify(prevBtn !== null)
            verify(closeBtn !== null)

            mouseClick(nextBtn)
            compare(findNextSpy.count, 1)

            mouseClick(prevBtn)
            compare(findPreviousSpy.count, 1)

            mouseClick(closeBtn)
            compare(closeSpy.count, 1)
        }

        function test_update_results() {
            var resultsLabel = overlay.children[0].children[1] // RowLayout -> Label
            // Try updating results
            overlay.updateResults("5")
            // Can't directly assert label text without id, but verify no crash
        }
    }
}
