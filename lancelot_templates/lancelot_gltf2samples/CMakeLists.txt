#####################################################################
## tst_gltf2tester Test:
#####################################################################

# Collect test data
list(APPEND test_data "../data")

qt_internal_add_test(tst_gltf2tester
    OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/.." # special case
    SOURCES
        ../shared/baselineprotocol.cpp ../shared/baselineprotocol.h
        ../shared/lookup3.cpp
        ../shared/qbaselinetest.cpp ../shared/qbaselinetest.h
        tst_gltf2tester.cpp
    INCLUDE_DIRECTORIES
        ../shared
    LIBRARIES
        Qt::Gui
        Qt::Network
    TESTDATA ${test_data}
)

# special case begin
add_dependencies(tst_gltf2tester Qt6::Quick3D)
add_dependencies(tst_gltf2tester qmlscenegrabber)
# special case end
