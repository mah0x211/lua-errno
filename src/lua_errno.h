/**
 *  Copyright (C) 2022 Masatoshi Fukunaga
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to
 *  deal in the Software without restriction, including without limitation the
 *  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 *  sell copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 *  IN THE SOFTWARE.
 */

#ifndef lua_errno_h
#define lua_errno_h

// lualib
#include <lua_error.h>

#define lua_errno_pushlib(L)                                                   \
 do {                                                                          \
  lua_getglobal((L), "errno");                                                 \
  if (lua_isnil((L), -1)) {                                                    \
   lua_pop(L, 1);                                                              \
   luaL_loadstring((L), "return require('errno')");                            \
   lua_call((L), 0, 1);                                                        \
  }                                                                            \
 } while (0)

static inline void lua_errno_loadlib(lua_State *L)
{
    int top = lua_gettop(L);
    lua_errno_pushlib(L);
    lua_settop(L, top);
}

static inline void lua_errno_pusherror(lua_State *L, int errnumidx)
{
    // get errno.new function
    lua_errno_pushlib(L);
    lua_getfield(L, -1, "new");
    lua_insert(L, errnumidx);
    lua_pop(L, 1);
    // call errno.new(errnum|errname, msg, op, err, traceback)
    lua_call(L, lua_gettop(L) - errnumidx, 1);
}
#undef lua_errno_pushlib

static inline void lua_errno_pusherrno(lua_State *L, int errnum)
{
    lua_pushinteger(L, errnum);
    lua_errno_pusherror(L, lua_gettop(L));
}

static inline void lua_errno_pusherrname(lua_State *L, const char *errname)
{
    lua_pushstring(L, errname);
    lua_errno_pusherror(L, lua_gettop(L));
}

#endif
