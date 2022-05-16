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

#define LUA_ERRNO_T_DEFAULT "errno.new"
#define LUA_ERRNO_T_EAI     "errno.eai.new"

static inline void lua_errno_loadlib(lua_State *L)
{
    int top = lua_gettop(L);

#define getref(L, t, libname)                                                  \
 do {                                                                          \
  lua_pushstring((L), (t));                                                    \
  lua_rawget((L), LUA_REGISTRYINDEX);                                          \
  if (!lua_isfunction((L), -1)) {                                              \
   lua_pop((L), 1);                                                            \
   luaL_loadstring((L), "return require(" #libname ")");                       \
   lua_call((L), 0, 1);                                                        \
   lua_pushstring((L), (t));                                                   \
   lua_getfield((L), -2, "new");                                               \
   luaL_checktype((L), -1, LUA_TFUNCTION);                                     \
   lua_rawset((L), LUA_REGISTRYINDEX);                                         \
  }                                                                            \
  lua_settop((L), (top));                                                      \
 } while (0)

    getref(L, LUA_ERRNO_T_DEFAULT, "errno");
    getref(L, LUA_ERRNO_T_EAI, "errno.eai");

#undef getref
}

static inline void lua_errno_new_ex(lua_State *L, const char *type, int errnum,
                                    const char *op, const char *msg, int erridx,
                                    int traceback)
{
    int top = lua_gettop(L);

    luaL_checkstack(L, top + 6, NULL);

    // get errno.new function
    lua_pushstring(L, type);
    lua_rawget(L, LUA_REGISTRYINDEX);
    if (!lua_isfunction(L, -1)) {
        // load the module if not loaded yet
        luaL_error(L, "\"errno\" module is not loaded by lua_errno_loadlib()");
    }
    lua_pushinteger(L, errnum);
    if (msg) {
        lua_pushstring((L), (msg));
    } else {
        lua_pushnil(L);
    }
    if (op) {
        lua_pushstring(L, op);
    } else {
        lua_pushnil(L);
    }
    if (erridx < 0) {
        lua_pushvalue(L, top + erridx + 1);
    } else if (erridx > 0) {
        lua_pushvalue(L, erridx);
    } else {
        lua_pushnil(L);
    }
    lua_pushboolean(L, traceback);
    // call errno.new(errnum, msg, op, err, traceback)
    lua_call(L, 5, 1);
}

static inline void lua_errno_new(lua_State *L, int errnum, const char *op)
{
    lua_errno_new_ex(L, LUA_ERRNO_T_DEFAULT, errnum, op, NULL, 0, 0);
}

static inline void lua_errno_eai_new(lua_State *L, int errnum, const char *op)
{
    lua_errno_new_ex(L, LUA_ERRNO_T_EAI, errnum, op, NULL, 0, 0);
}

#endif
