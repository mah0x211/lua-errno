# lua-errno

[![test](https://github.com/mah0x211/lua-errno/actions/workflows/test.yml/badge.svg)](https://github.com/mah0x211/lua-errno/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/mah0x211/lua-errno/branch/master/graph/badge.svg)](https://codecov.io/gh/mah0x211/lua-errno)


the errno handling module for lua.


## Installation

```sh
luarocks install errno
```

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
