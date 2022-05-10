local assert = require('assert')
local errno = require('errno')
local strerror = require('errno.strerror')

local function strerror_test()
    -- test that strerror returns the error string
    for _, err in pairs(errno) do
        assert.equal(strerror(err.code), err.message)
    end
end

strerror_test()
