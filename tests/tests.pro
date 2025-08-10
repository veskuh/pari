TEMPLATE = app
TARGET = tst_all
CONFIG += console
CONFIG -= app_bundle
QT += testlib core

# Include path to find the application headers
INCLUDEPATH += ../src

# Source files for the settings class being tested
SOURCES += \
    main.cpp \
    test_settings.cpp \
    test_filesystem.cpp \
    test_markdownformatter.cpp \
    ../src/app/filesystem.cpp \
    ../src/app/settings.cpp \
    ../src/app/markdownformatter.cpp

HEADERS += \
    test_settings.h \
    test_filesystem.h \
    test_markdownformatter.h \
    ../src/app/settings.h \
    ../src/app/filesystem.h \
    ../src/app/markdownformatter.h
