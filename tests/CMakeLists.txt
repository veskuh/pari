add_executable(tst_all
    main.cpp
    test_settings.cpp
    test_settings.h
    test_filesystem.cpp
    test_filesystem.h
    test_markdownformatter.cpp
    test_markdownformatter.h
    test_llm.cpp
    test_llm.h
    test_cppsyntaxhighlighter.cpp
    test_cppsyntaxhighlighter.h
    test_qmlsyntaxhighlighter.cpp
    test_qmlsyntaxhighlighter.h
    test_shellsyntaxhighlighter.cpp
    test_shellsyntaxhighlighter.h
    test_diffutils.cpp
    test_diffutils.h
    test_markdownsyntaxhighlighter.cpp
    test_markdownsyntaxhighlighter.h
    test_buildmanager.cpp
    test_buildmanager.h
    test_toolmanager.cpp
    test_toolmanager.h
    test_gitlogmodel.cpp
    test_gitlogmodel.h
    ../src/settings.cpp
    ../src/settings.h
    ../src/filesystem.cpp
    ../src/filesystem.h
    ../src/markdownformatter.cpp
    ../src/markdownformatter.h
    ../src/llm.cpp
    ../src/llm.h
    ../src/cppsyntaxhighlighter.cpp
    ../src/cppsyntaxhighlighter.h
    ../src/qmlsyntaxhighlighter.cpp
    ../src/qmlsyntaxhighlighter.h
    ../src/shellsyntaxhighlighter.cpp
    ../src/shellsyntaxhighlighter.h
    ../src/diffutils.cpp
    ../src/diffutils.h
    ../src/syntaxtheme.cpp
    ../src/syntaxtheme.h
    ../src/markdownsyntaxhighlighter.cpp
    ../src/markdownsyntaxhighlighter.h
    ../src/buildmanager.cpp
    ../src/buildmanager.h
    ../src/toolmanager.cpp
    ../src/toolmanager.h
    ../src/gitlogmodel.cpp
    ../src/gitlogmodel.h
)

target_include_directories(tst_all PRIVATE ../src)

target_link_libraries(tst_all PRIVATE
    Qt6::Test
    Qt6::Core
    Qt6::Network
    Qt6::Widgets
)

add_test(NAME AllTests COMMAND tst_all)
