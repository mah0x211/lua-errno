local assert = require('assert')
local errno = require('errno')
local get = require('errno.get')
local set = require('errno.set')
local strerror = require('errno.strerror')

local function set_get_test()
    -- test that set and get the errno
    set(errno.ENOENT.code)
    assert.equal(get(), errno.ENOENT.code)
    assert.equal(strerror(), errno.ENOENT.message)
end

set_get_test()
