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

-- set errno
print(errno(5))
-- get last errno
print(errno()) -- 5

-- get error.type object
-- by errno
print(errno[2]) -- ENOENT: 0x7f7fd540e898
-- by name
print(errno.ENOENT) -- ENOENT: 0x7f7fd540e898

-- create an error object from errno
local err = errno.new('EINTR')
print(err)
-- ./example.lua:15: in main chunk: [EINTR][code:4] Interrupted system call

-- create an error object with arguments
local msg = 'hello'
local op = 'my-op'
local traceback = true
local last_err = errno.new('ENOENT', msg, op, err, traceback)
print(last_err)
-- ./example.lua:23: in main chunk: [ENOENT][code:2] No such file or directory (hello)
-- stack traceback:
-- 	./example.lua:23: in main chunk
-- 	[C]: in ?
-- ./example.lua:15: in main chunk: [EINTR][code:4] Interrupted system call
```


## Use from C module

the `errno` module installs `lua_errno.h` in the lua include directory.

the following APIs are helper functions to use `errno` module in C module.


### void lua_errno_loadlib( lua_State *L )

load the `lua-errno` module.  

it is equivalent to the following code:

```lua
require('errno')
```


### void lua_errno_pusherror( lua_State *L, int errnumidx )

create new error from type of `errno[errnum]`.

it is equivalent to the following code:

```lua
local function errno_pusherror(errnum, op, msg, err, traceback)
    return require('errno').new(errnum, op, msg, err, traceback)
end
```

### Helper Macros

**void lua_errno_pusherrno( lua_State \*L, int errnum )**  

```c
lua_pushinteger(L, errnum);
lua_errno_pusherror(L, lua_gettop(L));
```

**void lua_errno_pusherrname( lua_State \*L, const char \*errname )**   

```c
lua_pushstring(L, errname);
lua_errno_pusherror(L, lua_gettop(L));
```
