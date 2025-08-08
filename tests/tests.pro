TEMPLATE = app
TARGET = tst_settings
CONFIG += console
CONFIG -= app_bundle
QT += testlib core

# Include path to find the application headers
INCLUDEPATH += ../src

# Source files for the settings class being tested
SOURCES += \
    test_settings.cpp \
    test_filesystem.cpp \
    ../src/app/filesystem.cpp

HEADERS += \
    ../src/app/settings.h \
    ../src/app/filesystem.h
