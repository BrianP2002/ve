cmake_minimum_required(VERSION 4.0.1)
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

add_custom_target(report
    COMMAND ${CMAKE_COMMAND} --build . --target me
    COMMAND ${CMAKE_COMMAND} --build . --target qme
    COMMAND ${CMAKE_COMMAND} --build . --target zme
    COMMAND sh ${CMAKE_SOURCE_DIR}/src/report.sh
)

add_custom_target(distrib
    COMMAND tar cf nme.tar \
        src/alloca.c src/allocs.c src/coin.c src/comline.c src/global.c src/input.c \
        src/input.tab.c src/lattice.c src/me.c src/memain.c src/myalloc.c src/out.c \
        src/pack.c src/push.c src/qinput.c src/scanner.c src/scrut.c src/vector.c \
        src/global.h src/ilatt.h src/input.h src/input.tab.h src/latt.h src/me.h \
        src/meint.h src/myalloc.h src/input.y src/Makefile src/Makefile.inc \
        src/ve/Makefile src/rat/Makefile src/int/Makefile src/build.sh \
        docs/nme.txi README src/report.sh examples src/GNUmakefile \
        src/ve/GNUmakefile src/rat/GNUmakefile src/int/GNUmakefile \
        bin/me.exe bin/qme.exe bin/zme.exe
    COMMAND compress nme.tar
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
)

add_custom_target(zoofile
    COMMAND zoo ah nme.zoo \
        src/alloca.c src/allocs.c src/coin.c src/comline.c src/global.c src/input.c \
        src/input.tab.c src/lattice.c src/me.c src/memain.c src/myalloc.c src/out.c \
        src/pack.c src/push.c src/qinput.c src/scanner.c src/scrut.c src/vector.c \
        src/global.h src/ilatt.h src/input.h src/input.tab.h src/latt.h src/me.h \
        src/meint.h src/myalloc.h src/input.y src/Makefile src/Makefile.inc \
        src/ve/Makefile src/rat/Makefile src/int/Makefile src/build.sh \
        docs/nme.txi README src/report.sh examples src/GNUmakefile \
        src/ve/GNUmakefile src/rat/GNUmakefile src/int/GNUmakefile \
        bin/me.exe bin/qme.exe bin/zme.exe
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
)
