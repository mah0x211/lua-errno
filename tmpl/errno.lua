--
-- Copyright (C) 2022 Masatoshi Fukunaga
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
local get_errno = require('errno.get')
local set_errno = require('errno.set')
local setmetatable = setmetatable

--- tostring
--- @return string
local function tostring(self)
    return self.message
end

--- new
--- @param name string
--- @param errno integer
--- @param message string
local function new(name, errno, message)
    return setmetatable({}, {
        __metatable = 0,
        __tostring = tostring,
        __index = {
            name = name,
            errno = errno,
            message = message,
        },
    })
end

local _M = {}
-- declare the error name
${ERRNO_NAME}
-- map errno to errname
${ERRNO_CODE}

--- call
--- @param _ table
--- @param v integer
--- @return integer
local function call(_, v)
    local errno = get_errno()
    if v ~= nil then
        set_errno(v)
    end
    return errno
end

return setmetatable( _M, {
    __call = call
})

