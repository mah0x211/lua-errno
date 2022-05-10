local concat = table.concat
local sort = table.sort
local format = string.format
local match = string.match
local gsub = string.gsub
local open = io.open
local popen = io.popen

-- get compiler
local function get_cc()
    for _, v in ipairs({
        'gcc',
        'clang',
    }) do
        local cmd = assert(popen('which ' .. v))
        local out = cmd:read('*a')

        out = match(out, '^%s*([^%s]+)%s*$')
        if #out > 0 then
            return out
        end
    end
    error('either gcc or clang is required.')
end

local CC = get_cc()
local CSRCFILE = 'var/check.c'
local EXECFILE = 'var/check.o'

-- generate c source file
local function render_c(filename, strerror)
    local SRC = [[
#include <errno.h>
#include <string.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>

int main(void){
%s
    return 0;
}
    ]]
    local LINE = [=[
#ifdef ${1}
    printf("${1}=%d=%s\n", ${1}, ]=] .. strerror .. [=[(${1}));
#endif
    ]=]

    local list = {}
    local f = assert(open(filename))

    for line in f:lines() do
        local name = line:match('^[_%w]+$')

        if not name then
            error('invalid line: ' .. line)
        elseif not list[name] then
            list[name] = gsub(LINE, '%${1}', name)
            -- keep symbol for sort
            list[#list + 1] = list[name]
        end
    end
    f:close()

    local src = format(SRC, concat(list, '\n'))
    f = assert(open(CSRCFILE, 'w+'))
    assert(f:write(src))
    f:close()
end

-- compile src file
local function compile(filename, strerror)
    render_c(filename, strerror)

    local cmd = assert(popen(concat({
        CC,
        CSRCFILE,
        '-o',
        EXECFILE,
        '2>&1',
    }, ' ')))
    local err = cmd:read('*a')
    assert(#err == 0, err)
end

-- extract
local function extract()
    local cmd = assert(popen(EXECFILE))
    local list = {}

    for line in cmd:lines() do
        local name, num, msg = match(line, '^([^=]+)=([^=]+)=(.+)$')
        list[#list + 1] = {
            name = name,
            num = tonumber(num),
            msg = msg,
        }
    end
    sort(list, function(a, b)
        return a.num < b.num
    end)

    local src_by_name = {}
    local src_by_code = {}
    for i, v in ipairs(list) do
        src_by_name[i] = format('_M.%s = new_error_type(%q, %d, %q)', v.name,
                                v.name, v.num, v.msg)
        src_by_code[i] = format('_M[%d] = _M.%s -- %q', v.num, v.name, v.msg)
    end

    return {
        ['BY_NAME'] = concat(src_by_name, '\n'),
        ['BY_CODE'] = concat(src_by_code, '\n'),
    }
end

-- render lua file
local function render_lua(filename, repl)
    local f = assert(open('tmpl/libtmpl.lua'))
    local tmpl = assert(f:read('*a'))
    local src = gsub(tmpl, '%${([^}]+)}', repl)
    f = assert(open(filename, 'w+'))
    f:write(src)
    f:close()
end

local repl = {}
for _, target in ipairs({
    {
        errlist = 'var/errno.txt',
        strerror = 'strerror',
        filename = 'errno.lua',
    },
}) do
    compile(target.errlist, target.strerror)
    for k, v in pairs(extract()) do
        repl[k] = v
    end
    render_lua(target.filename, repl)
end
