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

typedef enum {
    LUA_ERRNO_T_DEFAULT = 0,
    LUA_ERRNO_T_EAI,
    _LUA_ERRNO_T_MAX
} lua_errno_type_e;

static int LUA_ERRNO_REF[_LUA_ERRNO_T_MAX] = {LUA_NOREF, LUA_NOREF};

static inline void lua_errno_loadlib(lua_State *L)
{
    int top = lua_gettop(L);

#define getref(L, t, libname)                                                  \
 do {                                                                          \
  if (LUA_ERRNO_REF[t] == LUA_NOREF) {                                         \
   luaL_loadstring((L), "return require(" #libname ")");                       \
   lua_call((L), 0, 1);                                                        \
   lua_getfield((L), -1, "new");                                               \
   luaL_checktype(L, -1, LUA_TFUNCTION);                                       \
   LUA_ERRNO_REF[t] = lauxh_ref((L));                                          \
   lua_settop((L), (top));                                                     \
  }                                                                            \
 } while (0)

    getref(L, LUA_ERRNO_T_DEFAULT, "errno");
    getref(L, LUA_ERRNO_T_EAI, "errno.eai");

#undef getref
}

static inline void lua_errno_new_ex(lua_State *L, lua_errno_type_e type,
                                    int errnum, const char *op, const char *msg)
{
    // load the module if not loaded yet
    if (LUA_ERRNO_REF[type] == LUA_NOREF) {
        luaL_error(L, "\"errno\" module is not loaded by lua_errno_loadlib()");
    }

    // get errno.new function
    lauxh_pushref(L, LUA_ERRNO_REF[type]);
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
    // call errno.new(errnum, msg, op, err, traceback)
    lua_call(L, 3, 1);
}

static inline void lua_errno_new(lua_State *L, int errnum, const char *op)
{
    lua_errno_new_ex(L, LUA_ERRNO_T_DEFAULT, errnum, op, NULL);
}

static inline void lua_errno_eai_new(lua_State *L, int errnum, const char *op)
{
    lua_errno_new_ex(L, LUA_ERRNO_T_EAI, errnum, op, NULL);
}

#endif
