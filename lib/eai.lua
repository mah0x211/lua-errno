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
-- this file to be edited by code generator (codegen.lua)
--
local format = string.format
local tostring = tostring
-- luacheck: ignore new_error_type
local new_error_type = require('error').type.new
local new_error_mesage = require('error').message.new

local _M = {}
-- declare the error name
-- ${BY_NAME}
-- map errno to errname
-- ${BY_CODE}

--- new
--- @param num integer
--- @param msg any
--- @param op string
--- @param err any error object
--- @param traceback boolean
--- @return any err error object
local function new(num, msg, op, err, traceback)
    local t = _M[num]
    if not t then
        error(format('%q is not defined', tostring(num)), 2)
    elseif op then
        msg = new_error_mesage(msg, op, t.code)
    end
    return t:new(msg, err, 2, traceback)
end

local EXPORTS = {}
for k, v in pairs(_M) do
    EXPORTS[k] = v
end

return setmetatable(EXPORTS, {
    __index = {
        new = new,
    },
})
