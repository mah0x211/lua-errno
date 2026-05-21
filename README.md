# lua-errno

[![test](https://github.com/mah0x211/lua-errno/actions/workflows/test.yml/badge.svg)](https://github.com/mah0x211/lua-errno/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/mah0x211/lua-errno/branch/master/graph/badge.svg)](https://codecov.io/gh/mah0x211/lua-errno)


the errno handling module for lua.


## Installation

```sh
luarocks install errno
```

this module install the `lua_errno.h` to `CONFDIR` and creates a symbolic link in `LUA_INCDIR`.


## Lua API

### `local errno = require('errno')`

returns a table that maps both symbolic error names and numeric error codes to
the same error type object.

```lua
local errno = require('errno')

print(errno.ENOENT == errno[errno.ENOENT.code]) -- true
print(errno.ENOENT.name) -- ENOENT
print(errno.ENOENT.code) -- 2
print(errno.ENOENT.message) -- No such file or directory
```

each error type object is created by [lua-error](https://github.com/mah0x211/lua-error)
and exposes the standard `ErrType:new(...)` constructor.

### `err = errno.new(errnum [, msg [, op [, wrap [, traceback]]]])`

create an error object from an errno name or numeric errno code.

- `errnum`: errno name such as `"ENOENT"` or numeric code such as `2`.
- `msg`: optional message payload passed to the error object.
- `op`: optional operation name. if specified, it is stored in `err.op` and is
  reflected in the formatted error message.
- `wrap`: optional wrapped error object passed to `ErrType:new(...)`.
- `traceback`: optional boolean passed to `ErrType:new(...)`.

an unknown `errnum` raises an error.

```lua
local errno = require('errno')

-- create ENOENT error
-- please refer:
--  https://github.com/mah0x211/lua-error#err--errtnew-message--wrap--level--traceback-
local err = errno.ENOENT:new('hello')
print(err) -- ./example.lua:6: in main chunk: [ENOENT:2] No such file or directory (hello)
print(err.type, errno.ENOENT) -- ENOENT: 0x7f8898c0dd88 ENOENT: 0x7f8898c0dd88
print(err.code, errno.ENOENT.code) -- 2 2
print(err.message) -- hello
print(err.op) -- nil

-- create ENOENT error by new function
err = errno.new('ENOENT', 'world', 'example')
print(err) -- ./example.lua:14: in main chunk: [ENOENT:2][example] No such file or directory (world)
print(err.type, errno.ENOENT) -- ENOENT: 0x7f8898c0dd88 ENOENT: 0x7f8898c0dd88
print(err.code, errno.ENOENT.code) -- 2 2
print(err.message) -- world
print(err.op) -- example
```

### `local eai = require('errno.eai')`

returns the `getaddrinfo(3)` error table. it has the same interface as
`require('errno')`: symbolic names and numeric codes both map to the same error
type object, and `eai.new(...)` has the same signature as `errno.new(...)`.

```lua
local eai = require('errno.eai')

local err = eai.new('EAI_BADFLAGS', 'invalid hints', 'getaddrinfo')
print(err.type == eai.EAI_BADFLAGS) -- true
print(err.code) -- EAI_BADFLAGS code
print(err.op) -- getaddrinfo
```

### `local get = require('errno.get')`

returns the current C `errno` value.

```lua
local get = require('errno.get')

local errnum = get()
```

### `local set = require('errno.set')`

sets the current C `errno` value and defaults to `0` when called without an
argument.

```lua
local errno = require('errno')
local set = require('errno.set')

set(errno.ENOENT.code)
set() -- reset to 0
```

### `local strerror = require('errno.strerror')`

returns the error string for the given error number. if `errnum` is omitted, it
uses the current C `errno`.

```lua
local errno = require('errno')
local get = require('errno.get')
local set = require('errno.set')
local strerror = require('errno.strerror')

set(errno.ENOENT.code)
print(get()) -- 2
print(strerror()) -- No such file or directory
print(strerror(errno.EPERM.code)) -- Operation not permitted
```


## Use from C module

the `errno` module installs `lua_errno.h` in the lua include directory.

the following APIs are helper functions to use `errno` from a C module.

constructor helpers push the created error object onto the Lua stack.


### registry keys for `lua_errno_new_ex()`

use the predefined registry keys when selecting the cached constructor:

```c
LUA_ERRNO_T_DEFAULT /* errno.new */
LUA_ERRNO_T_EAI     /* errno.eai.new */
```


### void lua_errno_loadlib( lua_State *L )

loads and caches the constructor functions used by `lua_errno_new_ex()`.

**NOTE:** call this before `lua_errno_new_ex()`. it is not required for
`lua_errno_new()`, `lua_errno_new_with_message()`, or `lua_errno_eai_new()`.

this function restores the stack top before it returns.


### void lua_errno_new_ex( lua_State *L, const char *type, int errnum, const char *op, const char *msg, int erridx, int traceback )

low-level helper that retrieves a constructor function cached by
`lua_errno_loadlib()` and calls it with the following Lua-equivalent signature:

```lua
return constructor(errnum, msg, op, wrap, traceback)
```

- `type`: registry key of the cached constructor. pass
  `LUA_ERRNO_T_DEFAULT` or `LUA_ERRNO_T_EAI`.
- `errnum`: errno or EAI numeric code.
- `op`: optional operation name.
- `msg`: optional message string.
- `erridx`: stack index of the wrapped error object. use `0` for no wrapped
  error, a positive index for an absolute stack slot, or a negative index
  relative to the top of the stack.
- `traceback`: boolean flag passed to the Lua constructor.

this function pushes one error object onto the stack.


### void lua_errno_new( lua_State *L, int errnum, const char *op )

it is equivalent to the following code:

```lua
return require('errno').new(errnum, nil, op)
```

this function pushes one error object onto the stack.

### void lua_errno_new_with_message( lua_State *L, int errnum, const char *op, const char *msg )

it is equivalent to the following code:

```lua
return require('errno').new(errnum, msg, op)
```

this function pushes one error object onto the stack.

### void lua_errno_eai_new( lua_State *L, int errnum, const char *op )

it is equivalent to the following code:

```lua
return require('errno.eai').new(errnum, nil, op)
```

this function pushes one error object onto the stack.
