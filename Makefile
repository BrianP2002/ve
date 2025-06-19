SHELL = /bin/sh

INCDIRGMP = /usr/local/include
LIBDIRGMP = /usr/local/lib

CC = gcc
CFLAGS = -O2 -finline-functions
LFLAGS =
MEFLAGS =
BISON = bison

all: me qme zme

clean:
	( cd src ; rm -f int/*.o ve/*.o rat/*.o )

me:
	( cd src ; $(MAKE) PROGNAME="me" PROGDEF="-DME" OBJSDIR="ve" \
	OBJECTX="scrut.o" INCLUDEX="" MEFLAGS="$(MEFLAGS)" \
	CC="$(CC)" CFLAGS="$(CFLAGS)" INCDIRS="" \
	LD="$(CC)" LFLAGS="$(LFLAGS)" LIBDIRS="" LIBFILES="-lm" \
	BISON="$(BISON)" -f ../Makefile ../bin/me.exe )

qme:
	( cd src ; $(MAKE) PROGNAME="qme" PROGDEF="-DQME" OBJSDIR="rat" \
	OBJECTX="scrut.o" INCLUDEX="" MEFLAGS="$(MEFLAGS)" \
	CC="$(CC)" CFLAGS="$(CFLAGS)" INCDIRS="-I$(INCDIRGMP)" \
	LD="$(CC)" LFLAGS="$(LFLAGS)" LIBDIRS="-L$(LIBDIRGMP)" \
	LIBFILES="-lm -lgmp" BISON="$(BISON)" -f ../Makefile ../bin/qme.exe )

zme:
	( cd src ; $(MAKE) PROGNAME="zme" PROGDEF="-DZME" OBJSDIR="int" \
	OBJECTX="lattice.o" INCLUDEX="../latt.h" MEFLAGS="$(MEFLAGS)" \
	CC="$(CC)" CFLAGS="$(CFLAGS)" INCDIRS="-I$(INCDIRGMP)" \
	LD="$(CC)" LFLAGS="$(LFLAGS)" LIBDIRS="-L$(LIBDIRGMP)" \
	LIBFILES="-lm -lgmp" BISON="$(BISON)" -f ../Makefile ../bin/zme.exe )
