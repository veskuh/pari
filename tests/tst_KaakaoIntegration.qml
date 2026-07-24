import QtQuick
import QtTest
import Kaakao 1.0

TestCase {
    name: "KaakaoIntegration"
    when: windowShown

    KaakaoButton {
        id: testButton
        text: "Test Button"
    }

    KaakaoTextField {
        id: testTextField
        text: "Test Field"
    }

    function test_kaakaoComponentsAndTheme() {
        compare(testButton.text, "Test Button")
        compare(testTextField.text, "Test Field")
        verify(Theme.primaryAccent !== undefined)
    }
}
