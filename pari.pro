TEMPLATE = app
TARGET = pari
QT += quick qml network widgets
QML_IMPORT_PATH += qml

SOURCES += src/pari.cpp     src/llm.cpp     src/filesystem.cpp

RESOURCES += qml/qml.qrc

HEADERS +=     src/llm.h     src/filesystem.h

DISTFILES +=     qml/pari.qml

