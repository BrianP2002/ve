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
)

set(XTRAOBJS
    ${SRC_DIR}/scrut.c
)

if(BISON_FOUND)
    BISON_TARGET(MyParser ${SRC_DIR}/input.y ${CMAKE_CURRENT_BINARY_DIR}/input.tab.c
        DEFINES_FILE ${CMAKE_CURRENT_BINARY_DIR}/input.tab.h
    )
endif()

add_executable(me ${OBJS1} ${OBJS2} ${OBJS3} ${XTRAOBJS} ${BISON_MyParser_TARGET})

target_include_directories(me PRIVATE ${SRC_DIR} ${CMAKE_CURRENT_BINARY_DIR})
target_compile_definitions(me PRIVATE ME)
target_compile_options(me PRIVATE -O2 -finline-functions)
target_link_libraries(me PRIVATE m GMP)

set_target_properties(me PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bin
    OUTPUT_NAME "me.exe"
)
