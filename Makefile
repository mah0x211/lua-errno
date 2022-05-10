SRCS=$(wildcard src/*.c)
SOBJ=$(SRCS:.c=.$(LIB_EXTENSION))
LUALIBS=$(wildcard lib/*.lua)
INSTALL?=install
ifdef ERRNO_COVERAGE
COVFLAGS=--coverage
endif

.PHONY: preprocess all install

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
	$(INSTALL) -d $(INST_LUADIR)/errno
	$(INSTALL) $(LUALIBS) $(INST_LUADIR)/errno
	$(INSTALL) src/lua_errno.h $(CONFDIR)
	rm -f $(LUA_INCDIR)/lua_errno.h
	ln -s $(CONFDIR)/lua_errno.h $(LUA_INCDIR)
	rm -f ./src/*.o
	rm -f ./src/*.so
