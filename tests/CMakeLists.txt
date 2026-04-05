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
    test_gitmanager.cpp
    test_gitmanager.h
    test_documentmanager.cpp
    test_documentmanager.h
    test_syntaxtheme.cpp
    test_syntaxtheme.h
    ../src/core/settings.cpp
    ../src/core/settings.h
    ../src/core/filesystem.cpp
    ../src/core/filesystem.h
    ../src/formatting/markdownformatter.cpp
    ../src/formatting/markdownformatter.h
    ../src/integrations/llm.cpp
    ../src/integrations/llm.h
    ../src/formatting/cppsyntaxhighlighter.cpp
    ../src/formatting/cppsyntaxhighlighter.h
    ../src/formatting/qmlsyntaxhighlighter.cpp
    ../src/formatting/qmlsyntaxhighlighter.h
    ../src/formatting/shellsyntaxhighlighter.cpp
    ../src/formatting/shellsyntaxhighlighter.h
    ../src/core/diffutils.cpp
    ../src/core/diffutils.h
    ../src/formatting/syntaxtheme.cpp
    ../src/formatting/syntaxtheme.h
    ../src/formatting/markdownsyntaxhighlighter.cpp
    ../src/formatting/markdownsyntaxhighlighter.h
    ../src/integrations/buildmanager.cpp
    ../src/integrations/buildmanager.h
    ../src/integrations/toolmanager.cpp
    ../src/integrations/toolmanager.h
    ../src/integrations/gitlogmodel.cpp
    ../src/integrations/gitlogmodel.h
    ../src/integrations/gitmanager.cpp
    ../src/integrations/gitmanager.h
    ../src/editor/documentmanager.cpp
    ../src/editor/documentmanager.h
    ../src/editor/textdocument.cpp
    ../src/editor/textdocument.h
    ../src/editor/textdocumentsearcher.cpp
    ../src/editor/textdocumentsearcher.h
)

target_include_directories(tst_all PRIVATE ../src ../src/core ../src/editor ../src/formatting ../src/integrations)

target_link_libraries(tst_all PRIVATE
    Qt6::Test
    Qt6::Core
    Qt6::Network
    Qt6::Widgets
    Qt6::Qml
    Qt6::Quick
)

# UI Test Runner
add_executable(tst_ui
    test_ui_main.cpp
    ../assets/assets.qrc
    # Link sources for coverage
    ../src/core/settings.cpp
    ../src/core/filesystem.cpp
    ../src/formatting/markdownformatter.cpp
    ../src/integrations/llm.cpp
    ../src/formatting/cppsyntaxhighlighter.cpp
    ../src/formatting/qmlsyntaxhighlighter.cpp
    ../src/formatting/shellsyntaxhighlighter.cpp
    ../src/core/diffutils.cpp
    ../src/formatting/syntaxtheme.cpp
    ../src/formatting/markdownsyntaxhighlighter.cpp
    ../src/integrations/buildmanager.cpp
    ../src/integrations/toolmanager.cpp
    ../src/integrations/gitlogmodel.cpp
    ../src/integrations/gitmanager.cpp
    ../src/editor/documentmanager.cpp
    ../src/editor/textdocument.cpp
    ../src/editor/textdocumentsearcher.cpp
)

target_include_directories(tst_ui PRIVATE ../src ../src/core ../src/editor ../src/formatting ../src/integrations)

target_link_libraries(tst_ui PRIVATE
    Qt6::Test
    Qt6::QuickTest
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Widgets
    Qt6::Network
)

if(ENABLE_COVERAGE)
    add_custom_target(coverage
        COMMAND find . -name "*.gcda" -delete
        COMMAND ./tst_all
        COMMAND ./tst_ui -input ${CMAKE_CURRENT_SOURCE_DIR}
        COMMAND find . -name "*.gcno" -not -path "*_autogen*" -exec gcov -p {} +
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Generating coverage report for project sources"
    )
endif()

add_test(NAME AllTests COMMAND tst_all)
add_test(NAME UiTests COMMAND tst_ui -input ${CMAKE_CURRENT_SOURCE_DIR})
