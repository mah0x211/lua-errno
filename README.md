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
errno(2)
-- get last errno
assert(errno() == 2)

-- get error object by name
local err = errno.ENOENT
-- error object contains the 'name', 'code' and 'message' fields
assert(err.name == 'ENOENT')
assert(err.code == 2)
print(err.message)

-- get error object by number
assert(err == errno[2])
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


### void lua_errno_pusherror_ex( lua_State *L, int errnum, const char *op, const char *msg )

create new error from type of `errno[errnum]`.

it is equivalent to the following code:

```lua
local error = require('error')

local function errno_pusherror( errnum, op, msg )
    local errno = require('errno')
    local errt = errno[errnum]
    if not errt then
        error(format('errno[%d] is not type of error.type: %s', type(errno[errnum]))
    end
    local msg = error.message.new( msg or errt.message, op, errnum )
    return errt:new(msg)
end
```

### lua_errno_pusherror( lua_State *L, int errnum, const char *op )

helper macro equivalent to `lua_errno_pusherror_ex(L, errnum, op, NULL)`.

