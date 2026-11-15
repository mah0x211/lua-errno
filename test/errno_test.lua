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

local function errno_is_test()
    -- test that compare numeric codes, symbolic names, and error types
    assert.is_true(errno.is(errno.ENOENT.code, errno.ENOENT.code))
    assert.is_true(errno.is(errno.ENOENT.code, 'ENOENT'))
    assert.is_true(errno.is(errno.ENOENT.code, errno.ENOENT))
    assert.is_false(errno.is(errno.ENOENT.code, errno.EACCES.code))
    assert.is_false(errno.is(errno.ENOENT.code, 'EACCES'))
    assert.is_false(errno.is(errno.ENOENT.code, errno.EACCES))

    -- test that aliases compare by code rather than object identity
    assert.is_true(errno.is(errno.EAGAIN.code, 'EWOULDBLOCK'))
    assert.is_true(errno.is(errno.EAGAIN.code, errno.EWOULDBLOCK))

    -- test that only error types owned by errno are accepted
    assert.is_false(errno.is(errno.ENOENT.code, {
        code = errno.ENOENT.code,
    }))
    assert.is_false(errno.is(errno.ENOENT.code, {
        name = errno.ENOENT.name,
        code = errno.ENOENT.code,
        message = errno.ENOENT.message,
    }))
    assert.is_false(errno.is(errno.ENOENT.code, setmetatable({}, {
        __index = errno.ENOENT,
    })))
    local eai = require('errno.eai')
    assert.is_false(errno.is(eai.EAI_AGAIN.code, eai.EAI_AGAIN))

    -- test that numeric comparisons do not require a defined errno
    assert.is_true(errno.is(0, 0))
    assert.is_false(errno.is(0, 'ENOENT'))
    assert.is_false(errno.is(errno.ENOENT.code, 'UNKNOWN_ERRNO'))
    assert.is_false(errno.is(errno.ENOENT.code, tostring(errno.ENOENT.code)))

    -- test that absent or unsupported values do not match
    assert.is_false(errno.is(nil, 'ENOENT'))
    assert.is_false(errno.is('2', 'ENOENT'))
    assert.is_false(errno.is(nil, nil))
    assert.is_false(errno.is(errno.ENOENT.code, nil))
    assert.is_false(errno.is(errno.ENOENT.code, false))
    assert.is_false(errno.is(errno.ENOENT.code, {}))

    -- test that compare an errno returned by a read-only system call
    -- errno_test.lua is a regular file, so a child path cannot be opened.
    local file, err, errnum = io.open('test/errno_test.lua/missing', 'r')
    assert.is_nil(file)
    assert.is_string(err)
    assert.equal(errnum, errno.ENOTDIR.code)
    assert.is_true(errno.is(errnum, errno.ENOTDIR.code))
    assert.is_true(errno.is(errnum, 'ENOTDIR'))
    assert.is_true(errno.is(errnum, errno.ENOTDIR))
end

errno_is_test()
