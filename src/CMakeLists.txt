find_package(Qt6 COMPONENTS Core Gui Quick QuickControls2 Qml Network Widgets Test LabsSettings QuickDialogs2 REQUIRED)
qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(pari
    core/pari.cpp
    integrations/llm.cpp
    integrations/llm.h
    core/filesystem.cpp
    core/filesystem.h
    core/settings.cpp
    core/settings.h
    formatting/markdownformatter.cpp
    formatting/markdownformatter.h
    formatting/cppsyntaxhighlighter.cpp
    formatting/cppsyntaxhighlighter.h
    formatting/syntaxhighlighterprovider.cpp
    formatting/syntaxhighlighterprovider.h
    formatting/qmlsyntaxhighlighter.cpp
    formatting/qmlsyntaxhighlighter.h
    formatting/shellsyntaxhighlighter.cpp
    formatting/shellsyntaxhighlighter.h
    core/diffutils.cpp
    core/diffutils.h
    editor/textdocumentsearcher.cpp
    editor/textdocumentsearcher.h
    editor/editormanager.cpp
    editor/editormanager.h
    formatting/syntaxtheme.cpp
    formatting/syntaxtheme.h
    formatting/markdownsyntaxhighlighter.cpp
    formatting/markdownsyntaxhighlighter.h
    integrations/buildmanager.cpp
    integrations/buildmanager.h
    integrations/toolmanager.cpp
    integrations/toolmanager.h
    integrations/gitlogmodel.cpp
    integrations/gitlogmodel.h
    integrations/lspclient.cpp
    integrations/lspclient.h
    integrations/gitmanager.cpp
    integrations/gitmanager.h
    ../qml/qml.qrc
    ../assets/assets.qrc
)

target_include_directories(pari PRIVATE
    core
    editor
    formatting
    integrations
)

target_link_libraries(pari PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Qml
    Qt6::Network
    Qt6::Widgets
    Qt6::LabsSettings
    Qt6::QuickDialogs2
)

if(APPLE)
    set(ICON_FILE ${CMAKE_SOURCE_DIR}/assets/pari.icns)
    set_target_properties(pari PROPERTIES
        MACOSX_BUNDLE ON
        MACOSX_BUNDLE_ICON_FILE pari.icns
    )
    file(COPY ${ICON_FILE} DESTINATION ${CMAKE_BINARY_DIR}/src/pari.app/Contents/Resources)
elseif(WIN32)
    set_target_properties(pari PROPERTIES
        WIN32_EXECUTABLE ON
        RESOURCE_FILES ${CMAKE_SOURCE_DIR}/assets/pari.ico
    )
endif()
