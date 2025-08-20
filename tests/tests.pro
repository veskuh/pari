TEMPLATE = app
TARGET = tst_all
CONFIG += console
CONFIG -= app_bundle
QT += testlib core network widgets

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
    test_qmlsyntaxhighlighter.cpp \
    test_shellsyntaxhighlighter.cpp \
    test_diffutils.cpp \
    test_markdownsyntaxhighlighter.cpp \
    ../src/app/filesystem.cpp \
    ../src/app/settings.cpp \
    ../src/app/markdownformatter.cpp \
    ../src/app/llm.cpp \
    ../src/app/cppsyntaxhighlighter.cpp \
    ../src/app/qmlsyntaxhighlighter.cpp \
    ../src/app/shellsyntaxhighlighter.cpp \
    ../src/app/syntaxtheme.cpp \
    ../src/app/diffutils.cpp \
    ../src/app/markdownsyntaxhighlighter.cpp \
    ../src/app/filetreeproxymodel.cpp

HEADERS += \
    test_settings.h \
    test_filesystem.h \
    test_markdownformatter.h \
    test_llm.h \
    test_cppsyntaxhighlighter.h \
    test_qmlsyntaxhighlighter.h \
    test_shellsyntaxhighlighter.h \
    test_diffutils.h \
    test_markdownsyntaxhighlighter.h \
    ../src/app/settings.h \
    ../src/app/filesystem.h \
    ../src/app/markdownformatter.h \
    ../src/app/llm.h \
    ../src/app/cppsyntaxhighlighter.h \
    ../src/app/qmlsyntaxhighlighter.h \
    ../src/app/shellsyntaxhighlighter.h \
    ../src/app/diffutils.h \
    ../src/app/syntaxtheme.h \
    ../src/app/markdownsyntaxhighlighter.h \
    ../src/app/filetreeproxymodel.h

