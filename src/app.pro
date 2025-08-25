TEMPLATE = app
TARGET = pari
QT += quick qml network widgets

# Source files
HEADERS += \
    app/llm.h \
    app/filesystem.h \
    app/settings.h \
    app/markdownformatter.h \
    app/cppsyntaxhighlighter.h \
    app/syntaxhighlighterprovider.h \
    app/qmlsyntaxhighlighter.h \
    app/shellsyntaxhighlighter.h \
    app/diffutils.h \
    app/textdocumentsearcher.h \
    app/syntaxtheme.h \
    app/markdownsyntaxhighlighter.h \
    app/buildmanager.h \
    app/toolmanager.h \
    app/gitlogmodel.h

SOURCES += \
    app/pari.cpp \
    app/llm.cpp \
    app/filesystem.cpp \
    app/settings.cpp \
    app/markdownformatter.cpp \
    app/cppsyntaxhighlighter.cpp \
    app/syntaxhighlighterprovider.cpp \
    app/qmlsyntaxhighlighter.cpp \
    app/shellsyntaxhighlighter.cpp \
    app/diffutils.cpp \
    app/textdocumentsearcher.cpp \
    app/syntaxtheme.cpp \
    app/markdownsyntaxhighlighter.cpp \
    app/buildmanager.cpp \
    app/toolmanager.cpp \
    app/gitlogmodel.cpp

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
