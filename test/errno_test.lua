require('luacov')
local assert = require('assert')
local errno = require('errno')
local strerror = require('errno.strerror')

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

    -- test that set/get errno with __call metamethod
    for i = 5, 0, -1 do
        errno(i)
        assert.equal(errno(), i)
    end
end

local function strerror_test()
    -- test that strerror returns the error string
    for _, err in pairs(errno) do
        assert.equal(strerror(err.code), err.message)
    end
end

errno_test()
strerror_test()
