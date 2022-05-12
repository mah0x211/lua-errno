# lua-errno

[![test](https://github.com/mah0x211/lua-errno/actions/workflows/test.yml/badge.svg)](https://github.com/mah0x211/lua-errno/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/mah0x211/lua-errno/branch/master/graph/badge.svg)](https://codecov.io/gh/mah0x211/lua-errno)


the errno handling module for lua.


## Installation

```sh
luarocks install errno
```

this module install the `lua_errno.h` to `CONFDIR` and creates a symbolic link in `LUA_INCDIR`.


## Usage

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


## Use from C module

the `errno` module installs `lua_errno.h` in the lua include directory.

the following APIs are helper functions to use `errno` module in C module.


### void lua_errno_loadlib( lua_State *L )

load the `errno` module.  
**NOTE:** you must call this API at least once before using the following API.

it is equivalent to the following code:

```lua
require('errno')
require('errno.eai')
```


### void lua_errno_new( lua_State *L, int errnum, const char *op )

it is equivalent to the following code:

```lua
return require('errno').new(errnum, nil, op)
```

### void lua_errno_eai_new( lua_State *L, int errnum, const char *op )

it is equivalent to the following code:

```lua
return require('errno.eai').new(errnum, nil, op)
```
