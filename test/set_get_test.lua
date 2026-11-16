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

local function last_test()
    local saved = get()

    -- test that return the existing error type for the current errno
    set(errno.ENOENT.code)
    local enoent = errno.last()
    set(errno.EACCES.code)
    local eacces = errno.last()

    -- test that aliases use the existing numeric mapping
    set(errno.EWOULDBLOCK.code)
    local alias = errno.last()

    -- test that zero and undefined errno values return nil
    set(0)
    local zero = errno.last()
    set(-1)
    local unknown = errno.last()
    set(saved)

    assert.equal(enoent, errno.ENOENT)
    assert.equal(eacces, errno.EACCES)
    assert.equal(alias, errno[errno.EWOULDBLOCK.code])
    assert.is_nil(zero)
    assert.is_nil(unknown)
end

last_test()
