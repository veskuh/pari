# generate_version.cmake
find_package(Git QUIET)

set(PARI_VERSION "v0.0.0-dev")
set(PARI_BUILD_ID "unknown")

if(GIT_FOUND)
    # 1. Get Tag
    execute_process(COMMAND ${GIT_EXECUTABLE} describe --tags --match "v*" --abbrev=0
        WORKING_DIRECTORY "${SOURCE_DIR}"
        OUTPUT_VARIABLE GIT_TAG
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    
    if(GIT_TAG)
        set(PARI_VERSION "${GIT_TAG}")
    endif()

    # 2. Get Short SHA
    execute_process(COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
        WORKING_DIRECTORY "${SOURCE_DIR}"
        OUTPUT_VARIABLE GIT_SHA
        OUTPUT_STRIP_TRAILING_WHITESPACE)

    # 3. Check for modifications
    execute_process(COMMAND ${GIT_EXECUTABLE} status --porcelain
        WORKING_DIRECTORY "${SOURCE_DIR}"
        OUTPUT_VARIABLE GIT_STATUS
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    
    if(GIT_STATUS)
        set(PARI_BUILD_ID "${GIT_SHA}+modified")
    else()
        set(PARI_BUILD_ID "${GIT_SHA}")
    endif()
endif()

set(VERSION_CONTENT "// Generated file. Do not edit.\n#ifndef VERSION_H\n#define VERSION_H\n\n#define PARI_VERSION \"${PARI_VERSION}\"\n#define PARI_BUILD_ID \"${PARI_BUILD_ID}\"\n\n#endif // VERSION_H\n")

# Only write if changed to prevent unnecessary rebuilds
if(EXISTS "${OUTPUT_FILE}")
    file(READ "${OUTPUT_FILE}" OLD_CONTENT)
endif()

if(NOT "${VERSION_CONTENT}" STREQUAL "${OLD_CONTENT}")
    file(WRITE "${OUTPUT_FILE}" "${VERSION_CONTENT}")
endif()
