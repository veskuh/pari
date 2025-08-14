TEMPLATE = app
TARGET = tst_all
CONFIG += console
CONFIG -= app_bundle
QT += testlib core network

# Include path to find the application headers
INCLUDEPATH += ../src

# Source files for the settings class being tested
SOURCES += \
    main.cpp \
    test_settings.cpp \
    test_filesystem.cpp \
    test_markdownformatter.cpp \
    test_llm.cpp \
    test_cppsyntaxhighlighter.cpp \
    test_diffutils.cpp \
    ../src/app/filesystem.cpp \
    ../src/app/settings.cpp \
    ../src/app/markdownformatter.cpp \
    ../src/app/llm.cpp \
    ../src/app/cppsyntaxhighlighter.cpp \
    ../src/app/diffutils.cpp

HEADERS += \
    test_settings.h \
    test_filesystem.h \
    test_markdownformatter.h \
    test_llm.h \
    test_cppsyntaxhighlighter.h \
    test_diffutils.h \
    ../src/app/settings.h \
    ../src/app/filesystem.h \
    ../src/app/markdownformatter.h \
    ../src/app/llm.h \
    ../src/app/cppsyntaxhighlighter.h \
    ../src/app/diffutils.h
