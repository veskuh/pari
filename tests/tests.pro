TEMPLATE = app
TARGET = tst_settings
CONFIG += console
CONFIG -= app_bundle
QT += testlib core

# Include path to find the application headers
INCLUDEPATH += ../src

# Source files for the settings class being tested
SOURCES += \
    ../src/app/settings.cpp \
    test_settings.cpp

HEADERS += \
    ../src/app/settings.h
