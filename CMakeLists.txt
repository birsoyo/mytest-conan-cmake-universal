cmake_minimum_required(VERSION 3.20)
project(mytest)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/builds/mytest-conan)
list(APPEND CMAKE_PREFIX_PATH ${CMAKE_SOURCE_DIR}/builds/mytest-conan)

find_package(fmt)

add_executable(main main.cpp)
target_compile_features(main PUBLIC cxx_std_17)
target_link_libraries(main PUBLIC fmt::fmt)
