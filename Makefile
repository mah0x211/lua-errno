SRCS=$(wildcard src/*.c)
SOBJ=$(SRCS:.c=.$(LIB_EXTENSION))
INSTALL?=install
ifdef ERRNO_COVERAGE
COVFLAGS=--coverage
endif

.PHONY: preprocess all install clean

all: preprocess $(SOBJ)

%.o: %.c
	$(CC) $(CFLAGS) $(WARNINGS) $(COVFLAGS) $(CPPFLAGS) -o $@ -c $<

%.$(LIB_EXTENSION): %.o
	$(CC) -o $@ $^ $(LDFLAGS) $(LIBS) $(PLATFORM_LDFLAGS) $(COVFLAGS)

preprocess:
	lua ./codegen.lua

install: $(SOBJ)
	$(INSTALL) -d $(INST_LIBDIR)
	$(INSTALL) $(SOBJ) $(INST_LIBDIR)
	$(INSTALL) errno.lua $(INST_LUADIR)
	rm -f ./src/*.o
	rm -f ./src/*.so
