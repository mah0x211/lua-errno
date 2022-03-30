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
-- error object contains the 'name', 'errno' and 'message' fields
assert(err.name == 'ENOENT')
assert(err.errno == 2)
-- __tostring metamethod returns the value of err.message field
print(err)

-- get error object by number
assert(noent == errno[2])
```
