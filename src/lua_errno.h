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

static inline void lua_errno_pusherror_ex(lua_State *L, int errnum,
                                          const char *op, const char *msg)
{
    int top            = lua_gettop(L);
    le_error_type_t *t = NULL;

    lua_errno_pushlib(L);
    // get errno[errnum]
    lua_rawgeti(L, -1, errnum);
    if (!lauxh_ismetatableof(L, -1, LE_ERROR_TYPE_MT)) {
        lua_pushfstring(L, "errno[%d] is not type of " LE_ERROR_TYPE_MT ": %s",
                        errnum, luaL_typename(L, -1));
        lua_error(L);
    }
    t = (le_error_type_t *)lua_touserdata(L, -1);
    lua_replace(L, top + 1);

    // create error message { message = msg, op = op, code = errnum }
    if (msg) {
        lua_pushstring(L, msg);
    } else {
        lauxh_pushref(L, t->ref_msg);
    }
    if (op) {
        lua_pushstring(L, op);
    } else {
        lua_pushnil(L);
    }
    lua_pushinteger(L, errnum);
    le_new_message(L, top + 2);
    le_new_typed_error(L, top + 1);
}

#define lua_errno_pusherror(L, errnum, op)                                     \
 lua_errno_pusherror_ex(L, errnum, op, NULL)

#undef lua_errno_pushlib

#endif
