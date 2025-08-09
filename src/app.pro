TEMPLATE = app
TARGET = pari
QT += quick qml network widgets

# Source files
HEADERS += \
    app/llm.h \
    app/filesystem.h \
    app/settings.h

SOURCES += \
    app/pari.cpp \
    app/llm.cpp \
    app/filesystem.cpp \
    app/settings.cpp

# QML resources
RESOURCES += \
    qml/qml.qrc \
    ../assets/assets.qrc

macx {
    ICON = ../assets/pari.icns
    RC_FILE = ../assets/pari.icns
}
win32: ICON = ../assets/pari.ico
unix:!macx: ICON = ../assets/pari.png