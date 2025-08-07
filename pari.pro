TEMPLATE = app
TARGET = pari
QT += quick qml network widgets
HEADERS +=     src/llm.h     src/filesystem.h src/settings.h
SOURCES += src/pari.cpp     src/llm.cpp     src/filesystem.cpp src/settings.cpp
RESOURCES += qml/qml.qrc
