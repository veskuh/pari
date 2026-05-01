find_package(Qt6 COMPONENTS Core Gui Quick QuickControls2 Qml Network Widgets Test LabsSettings QuickDialogs2 Concurrent REQUIRED)
qt_standard_project_setup(REQUIRES 6.5)

# --- BUILD-TIME VERSION DETECTION ---
set(VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/core/version.h")
add_custom_command(
    OUTPUT "${VERSION_HEADER}"
    COMMAND ${CMAKE_COMMAND} 
        -DSOURCE_DIR=${CMAKE_SOURCE_DIR} 
        -DOUTPUT_FILE=${VERSION_HEADER} 
        -P "${CMAKE_CURRENT_SOURCE_DIR}/core/generate_version.cmake"
    DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/core/generate_version.cmake"
    BYPRODUCTS "${VERSION_HEADER}"
    COMMENT "Updating version information..."
    VERBATIM
)

qt_add_executable(pari
    core/pari.cpp
    integrations/llm.cpp
    integrations/llm.h
    core/filesystem.cpp
    core/filesystem.h
    core/settings.cpp
    core/settings.h
    core/projectsearchmodel.cpp
    core/projectsearchmodel.h
    formatting/markdownformatter.cpp
    formatting/markdownformatter.h
    formatting/cppsyntaxhighlighter.cpp
    formatting/cppsyntaxhighlighter.h
    formatting/swiftsyntaxhighlighter.cpp
    formatting/swiftsyntaxhighlighter.h
    formatting/jssyntaxhighlighter.cpp
    formatting/jssyntaxhighlighter.h
    formatting/javasyntaxhighlighter.cpp
    formatting/javasyntaxhighlighter.h
    formatting/kotlinsyntaxhighlighter.cpp
    formatting/kotlinsyntaxhighlighter.h
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
    editor/documentmanager.cpp
    editor/documentmanager.h
    editor/textdocument.cpp
    editor/textdocument.h
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
    integrations/gitblamemodel.cpp
    integrations/gitblamemodel.h
    integrations/gitdiffmodel.cpp
    integrations/gitdiffmodel.h
    integrations/lspclient.cpp
    integrations/lspclient.h
    integrations/gitmanager.cpp
    integrations/gitmanager.h
    ../qml/qml.qrc
    ../assets/assets.qrc
    ${VERSION_HEADER}
)

target_include_directories(pari PRIVATE
    core
    editor
    formatting
    integrations
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}/core
)

target_link_libraries(pari PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Qml
    Qt6::Network
    Qt6::Widgets
    Qt6::LabsSettings
    Qt6::QuickDialogs2
    Qt6::Concurrent
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

# --- CROSS-PLATFORM DEPLOYMENT ---
include(GNUInstallDirs)

if(APPLE)
    # On macOS, install the .app bundle to /Applications by default
    # but respect CMAKE_INSTALL_PREFIX if set (e.g. /usr/local)
    install(TARGETS pari
        BUNDLE DESTINATION /Applications
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )
else()
    # LINUX DEPLOYMENT
    # 1. Install Binary (Force fresh install by being explicit)
    install(TARGETS pari
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        COMPONENT Application
    )

    # 2. Install Icon
    install(FILES ../assets/pari.png
        DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/512x512/apps
        COMPONENT Application
    )

    # 3. Configure and Install Desktop File
    configure_file(../assets/pari.desktop.in pari.desktop @ONLY)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/pari.desktop
        DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
        COMPONENT Application
    )
endif()
