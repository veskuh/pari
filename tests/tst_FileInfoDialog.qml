import QtQuick
import QtTest
import QtQuick.Controls
import QtQuick.Layouts
import "../qml/filetree"

Item {
    width: 600
    height: 400

    FileInfoDialog {
        id: fileInfoDialog
        fileName: "test.txt"
        filePath: "/path/to/test.txt"
        fileSize: "1024 bytes"
        fileModified: "2023-10-27 10:00:00"
    }

    TestCase {
        name: "FileInfoDialogTests"
        when: windowShown

        function init() {
            // Nothing to init
        }

        function test_initial_state() {
            compare(fileInfoDialog.title, "File Info")
            compare(fileInfoDialog.fileName, "test.txt")
            compare(fileInfoDialog.filePath, "/path/to/test.txt")
            compare(fileInfoDialog.fileSize, "1024 bytes")
            compare(fileInfoDialog.fileModified, "2023-10-27 10:00:00")
            compare(fileInfoDialog.width, 400)
            compare(fileInfoDialog.height, 180)
        }

        function test_property_updates() {
            fileInfoDialog.fileName = "new_test.txt"
            compare(fileInfoDialog.fileName, "new_test.txt")

            fileInfoDialog.filePath = "/new/path/to/test.txt"
            compare(fileInfoDialog.filePath, "/new/path/to/test.txt")

            fileInfoDialog.fileSize = "2048 bytes"
            compare(fileInfoDialog.fileSize, "2048 bytes")

            fileInfoDialog.fileModified = "2023-10-28 11:00:00"
            compare(fileInfoDialog.fileModified, "2023-10-28 11:00:00")
        }
    }
}
