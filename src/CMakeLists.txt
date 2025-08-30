qt_add_executable(pari
    pari.cpp
    llm.cpp
    llm.h
    filesystem.cpp
    filesystem.h
    settings.cpp
    settings.h
    markdownformatter.cpp
    markdownformatter.h
    cppsyntaxhighlighter.cpp
    cppsyntaxhighlighter.h
    syntaxhighlighterprovider.cpp
    syntaxhighlighterprovider.h
    qmlsyntaxhighlighter.cpp
    qmlsyntaxhighlighter.h
    shellsyntaxhighlighter.cpp
    shellsyntaxhighlighter.h
    diffutils.cpp
    diffutils.h
    textdocumentsearcher.cpp
    textdocumentsearcher.h
    syntaxtheme.cpp
    syntaxtheme.h
    markdownsyntaxhighlighter.cpp
    markdownsyntaxhighlighter.h
    buildmanager.cpp
    buildmanager.h
    toolmanager.cpp
    toolmanager.h
    gitlogmodel.cpp
    gitlogmodel.h
    ../qml/qml.qrc
    ../assets/assets.qrc
    ../assets/pari.icns
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
    set_target_properties(pari PROPERTIES
        MACOSX_BUNDLE ON
        MACOSX_BUNDLE_ICON_FILE pari.icns
    )
elseif(WIN32)
    set_target_properties(pari PROPERTIES
        WIN32_EXECUTABLE ON
        RESOURCE_FILES ${CMAKE_SOURCE_DIR}/assets/pari.ico
    )
endif()
