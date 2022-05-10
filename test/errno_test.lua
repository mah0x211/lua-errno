require('luacov')
local assert = require('assert')
local errno = require('errno')

local function errno_test()
    -- test that verify the mapping table
    for k, v in pairs(errno) do
        if type(k) == 'string' then
            assert.equal(v.name, k)
            assert.equal(errno[v.code].message, v.message)
        elseif type(k) == 'number' then
            assert.equal(v.code, k)
            assert.equal(errno[v.name], v)
        end
    end

    -- test that create new error from error number
    local err = errno.new(errno.ENOENT.code)
    assert.equal(err.type, errno.ENOENT)
    assert.equal(err.code, errno.ENOENT.code)
    assert.is_nil(err.op)
    assert.is_nil(err.message.message)

    -- test that create new error from name of error number
    err = errno.new('ENOENT')
    assert.equal(err.type, errno.ENOENT)
    assert.equal(err.code, errno.ENOENT.code)
    assert.is_nil(err.op)
    assert.is_nil(err.message.message)

    -- test that create new error with message
    err = errno.new('ENOENT', 'hello')
    assert.equal(err.type, errno.ENOENT)
    assert.equal(err.code, errno.ENOENT.code)
    assert.is_nil(err.op)
    assert.equal(err.message.message, 'hello')

    -- test that create new error with message and op
    err = errno.new('ENOENT', 'hello', 'world')
    assert.equal(err.type, errno.ENOENT)
    assert.equal(err.code, errno.ENOENT.code)
    assert.equal(err.op, 'world')
    assert.equal(err.message.message, 'hello')

    -- test that create new error with op
    err = errno.new('ENOENT', nil, 'world')
    assert.equal(err.type, errno.ENOENT)
    assert.equal(err.code, errno.ENOENT.code)
    assert.equal(err.op, 'world')
    assert.is_nil(err.message.message)

    -- test that throw an error if unknown errno
    err = assert.throws(errno.new, 'foo')
    assert.match(err, '"foo" is not defined')
end

errno_test()
