if (NOT QT_BUILD_STANDALONE_TESTS AND NOT QT_BUILDING_QT)
    cmake_minimum_required(VERSION 3.16)
    project(qtquick3d_gltf_baselinetest LANGUAGES C CXX)
endif()

add_subdirectory(scenegrabber)
add_subdirectory(lancelot_gltf2samples)
