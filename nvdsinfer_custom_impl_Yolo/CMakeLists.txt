# Minimum required version of CMake
cmake_minimum_required(VERSION 3.10)
set(CMAKE_CUDA_COMPILER /usr/local/cuda/bin/nvcc)
# Project name and version
project(nvdsinfer_custom_impl_Yolo VERSION 1.0 LANGUAGES CXX CUDA)

# Установка пути к компилятору CUDA


# CPack settings for DEB package
set(CPACK_PACKAGE_NAME "nvdsinfer_custom_impl_Yolo")
set(CPACK_PACKAGE_VERSION "1.0")
set(CPACK_PACKAGE_CONTACT "Your Name <your.email@example.com>")
set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${CMAKE_CURRENT_SOURCE_DIR}/postinst;${CMAKE_CURRENT_SOURCE_DIR}/prerm")

# Include CPack module
include(CPack)

# Options for OpenCV and Graph support
option(OPENCV "Enable OpenCV support" OFF)
option(GRAPH "Enable Graph support" OFF)

# Compiler settings
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -shared -fPIC -Wno-error=deprecated-declarations")

# Include directories
include_directories(
    /opt/nvidia/deepstream/deepstream/sources/includes
    /usr/local/cuda/include
)

link_directories(
    /usr/local/cuda/lib64
)

if(OPENCV)
    add_definitions(-DOPENCV)
    find_package(OpenCV REQUIRED)
    include_directories(${OpenCV_INCLUDE_DIRS})
endif()

if(GRAPH)
    add_definitions(-DGRAPH)
endif()

# Source files
file(GLOB_RECURSE SRCFILES
    # ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/nvdsinfer_yolo_engine.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/nvdsinitinputlayers_Yolo.cpp  
    ${CMAKE_CURRENT_SOURCE_DIR}/nvdsparsebbox_Yolo.cpp  
    ${CMAKE_CURRENT_SOURCE_DIR}/utils.cpp  
    ${CMAKE_CURRENT_SOURCE_DIR}/yolo.cpp  
    ${CMAKE_CURRENT_SOURCE_DIR}/yoloPlugins.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/layers/*.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/*.cu
)
list(REMOVE_ITEM SRCFILES ${CMAKE_CURRENT_SOURCE_DIR}/calibrator.cpp)

if(OPENCV)
    list(APPEND SRCFILES ${CMAKE_CURRENT_SOURCE_DIR}/calibrator.cpp)
endif()

# Add library
add_library(nvdsinfer_custom_impl_Yolo SHARED ${SRCFILES})

# Link libraries
target_link_libraries(nvdsinfer_custom_impl_Yolo
    nvinfer_plugin
    nvinfer
    nvparsers
    nvonnxparser
    cudart
    cublas
    stdc++fs
)

if(OPENCV)
    target_link_libraries(nvdsinfer_custom_impl_Yolo ${OpenCV_LIBS})
endif()

# Set CUDA properties
set_target_properties(nvdsinfer_custom_impl_Yolo PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON
    POSITION_INDEPENDENT_CODE ON
    CUDA_ARCHITECTURES 52
)

# Install target
install(TARGETS nvdsinfer_custom_impl_Yolo
    LIBRARY DESTINATION lib
)

# Include headers in the package
file(GLOB HEADER_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.h ${CMAKE_CURRENT_SOURCE_DIR}/layers/*.h)
install(FILES ${HEADER_FILES} DESTINATION include/nvdsinfer_custom_impl_Yolo)
