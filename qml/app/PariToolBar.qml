import QtQuick
import Kaakao 1.0

KaakaoToolBar {
    id: root
    readonly property bool isDark: (typeof appSettings !== 'undefined' && appSettings !== null) ? appSettings.systemThemeIsDark : false
}
