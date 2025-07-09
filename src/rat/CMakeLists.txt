cmake_minimum_required(VERSION 4.0.1)

find_package(BISON REQUIRED)

set(SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/..)

set(OBJS1
    ${SRC_DIR}/myalloc.c
    ${SRC_DIR}/global.c
)

set(OBJS2
    ${SRC_DIR}/pack.c
    ${SRC_DIR}/allocs.c
    ${SRC_DIR}/out.c
    ${SRC_DIR}/push.c
    ${SRC_DIR}/comline.c
    ${SRC_DIR}/qinput.c
    ${SRC_DIR}/memain.c
    ${SRC_DIR}/me.c
    ${SRC_DIR}/coin.c
    ${SRC_DIR}/vector.c
)

set(OBJS3
    ${SRC_DIR}/scanner.c
    ${SRC_DIR}/inputfun.c
    ${CMAKE_CURRENT_BINARY_DIR}/input.tab.c
)

set(XTRAOBJS
    ${SRC_DIR}/scrut.c
)

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/input.tab.c ${CMAKE_CURRENT_BINARY_DIR}/input.tab.h
    COMMAND ${BISON_EXECUTABLE} -d ${SRC_DIR}/input.y -o ${CMAKE_CURRENT_BINARY_DIR}/input.tab.c
    DEPENDS ${SRC_DIR}/input.y
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)

add_custom_target(parser_rat DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/input.tab.c ${CMAKE_CURRENT_BINARY_DIR}/input.tab.h)

add_executable(qme ${OBJS1} ${OBJS2} ${OBJS3} ${XTRAOBJS})
add_dependencies(qme parser_rat)

target_include_directories(qme PRIVATE ${SRC_DIR} ${CMAKE_CURRENT_BINARY_DIR})
target_compile_definitions(qme PRIVATE QME)
target_compile_options(qme PRIVATE -O2 -finline-functions)
target_link_libraries(qme PRIVATE m gmp)

set_target_properties(qme PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bin
    OUTPUT_NAME "qme.exe"
)
