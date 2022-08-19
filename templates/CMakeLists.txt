cmake_minimum_required(VERSION 3.16)

project(glTFSampleViewer VERSION 1.0 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 COMPONENTS Quick Quick3D REQUIRED)

if (APPLE)
    # This code bundles resource data on macOS and iOS (correctly)
    # Get a list of all of the files in the data-folder.
    file(GLOB_RECURSE TEST_RESOURCES "${CMAKE_CURRENT_SOURCE_DIR}/models/*")

    # Individually set the file's path properties.
    foreach (FILE ${TEST_RESOURCES})
        # Get the relative path from the data-folder to the particular file.
        file(RELATIVE_PATH NEW_FILE "${CMAKE_CURRENT_SOURCE_DIR}/models" ${FILE})

        # Get the relative path to the file.
        get_filename_component(NEW_FILE_PATH ${NEW_FILE} DIRECTORY)

        # Set it's location inside the app package (under Resources).
        set_property(SOURCE ${FILE} PROPERTY MACOSX_PACKAGE_LOCATION "Resources/models/${NEW_FILE_PATH}")

        # Optional: Add the file to the 'Resources' folder group in Xcode.
        #           This also preserves folder structure.
        source_group("Resources/models/${NEW_FILE_PATH}" FILES "${FILE}")
    endforeach ()
endif ()

qt_add_executable(glTFSampleViewer
    main.cpp
    pathhelper.h pathhelper.cpp
    ${TEST_RESOURCES}
)

set_target_properties(glTFSampleViewer PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER gltfSampleViewer.qt.io
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

qt_add_qml_module(glTFSampleViewer
    URI "glTFSampleViewer"
    VERSION "${PROJECT_VERSION}"
    QML_FILES 
        GltfTestViewer.qml
        GltfTestsModel.qml
    NO_RESOURCE_TARGET_PATH
)

target_link_libraries(glTFSampleViewer
    PRIVATE Qt6::Quick Qt6::Quick3D)

install(TARGETS glTFSampleViewer
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
