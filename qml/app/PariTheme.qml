import QtQuick
import Kaakao

QtObject {
    id: root

    property Binding themeBinding: Binding {
        target: Theme
        property: "themeMode"
        value: (typeof appSettings !== 'undefined' && appSettings !== null && appSettings.systemThemeIsDark !== undefined)
               ? (appSettings.systemThemeIsDark ? Theme.Dark : Theme.Light)
               : Theme.System
    }

    readonly property bool isDark: Theme.isDarkMode

    // --- Colors: Surfaces (sourced from Kaakao Theme) ---
    readonly property color sidebarBg: Theme.sidebarBackground
    readonly property color sidebarBorder: Theme.sidebarBorder
    readonly property color editorBg: Theme.contentBackground
    readonly property color editorBorder: Theme.textFieldBorder
    readonly property color windowBg: Theme.windowBackground

    // --- Colors: Text (sourced from Kaakao Theme) ---
    readonly property color textColor: Theme.primaryText
    readonly property color textColorMuted: Theme.secondaryText
    readonly property color textColorDim: Theme.secondaryText
    readonly property color textColorInverse: Theme.accentButtonText
    readonly property color accentColor: Theme.primaryAccent

    // --- Colors: Buttons (sourced from Kaakao Theme) ---
    readonly property color btnLightTop: Theme.buttonGradTop
    readonly property color btnLightBottom: Theme.buttonGradBottom
    readonly property color btnLightBorder: Theme.buttonBorder
    readonly property color btnLightPrimaryTop: Theme.accentGradTop
    readonly property color btnLightPrimaryBottom: Theme.accentGradBottom

    readonly property color btnDarkTop: Theme.buttonGradTop
    readonly property color btnDarkBottom: Theme.buttonGradBottom
    readonly property color btnDarkBorder: Theme.buttonBorder
    readonly property color btnDarkPrimaryTop: Theme.accentGradTop
    readonly property color btnDarkPrimaryBottom: Theme.accentGradBottom

    // --- Metrics: Paddings & Margins (sourced from Kaakao Theme) ---
    readonly property real paddingSmall: Theme.paddingSmall
    readonly property real paddingMedium: Theme.paddingMedium
    readonly property real marginStandard: Theme.standardPadding
    readonly property real borderRadius: Theme.radiusStandard

    // --- Custom pari properties (no Kaakao equivalent) ---
    readonly property color editorBgDirty: isDark ? "#1e2538" : "#fffdf0"
    readonly property real paddingLarge: 12
    readonly property string monoFont: (typeof appSettings !== 'undefined' && appSettings && appSettings.fontFamily) ? appSettings.fontFamily : (Qt.platform.os === 'osx' ? "Menlo" : "monospace")
    readonly property int fontSize: (typeof appSettings !== 'undefined' && appSettings && appSettings.fontSize) ? appSettings.fontSize : 12
    readonly property int fontToolbar: 11
    readonly property int fontButton: 13
    readonly property int fontSizeSmall: fontSize - 1
    readonly property int fontSizeLarge: fontSize + 2
}
