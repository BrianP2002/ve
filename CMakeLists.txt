cmake_minimum_required(VERSION 3.10)
project(ve LANGUAGES C CXX)

set(GMPHEAD "/usr/local/include")
set(GMPLIB "/usr/local/lib")

include_directories(${GMPHEAD} src)
link_directories(${GMPLIB})

add_subdirectory(src/int)
add_subdirectory(src/rat)
add_subdirectory(src/ve)

add_library(ve_kernel MODULE src/ve/ve.cc)
target_compile_options(ve_kernel PRIVATE -O2 -finline-functions)
set_target_properties(ve_kernel PROPERTIES
    PREFIX ""
    OUTPUT_NAME "ve"
    LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bin
)

add_custom_target(clean-all
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/clean-all.cmake
)
