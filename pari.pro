TEMPLATE = app
TARGET = pari
QT += quick qml network

SOURCES += src/pari.cpp \
    src/llm.cpp

RESOURCES += qml/qml.qrc

HEADERS += \
    src/llm.h

DISTFILES +=     qml/pari.qml

