local concat = table.concat
local sort = table.sort
local format = string.format
local match = string.match
local gsub = string.gsub
local open = io.open
local popen = io.popen

-- get compiler
local CC
for _, v in ipairs({
    'gcc',
    'clang',
}) do
    local cmd = assert(popen('which ' .. v))
    local out = cmd:read('*a')

    out = match(out, '^%s*([^%s]+)%s*$')
    if #out > 0 then
        CC = out
        break
    end
end
if not CC then
    error('either gcc or clang is required.')
end

-- generate src file
do
    local SRC = [[
#include <errno.h>
#include <string.h>
#include <stdio.h>

int main(void){
%s
    return 0;
}
    ]]
    local LINE = [=[
#ifdef ${1}
    printf("${1}=%d=%s\n", ${1}, strerror(${1}));
#endif
    ]=]

    local list = {}
    local f = assert(open('var/errno.txt'))

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
    f = assert(open('var/errno.c', 'w+'))
    assert(f:write(src))
    f:close()
end

-- compile src file
do
    local cmd = assert(popen(concat({
        CC,
        'var/errno.c',
        '-o',
        'var/errno.out',
        '2>&1',
    }, ' ')))
    local err = cmd:read('*a')
    assert(#err == 0, err)
end

-- extract errno
local errno = {}
do
    local cmd = assert(popen('var/errno.out'))

    for line in cmd:lines() do
        local name, num, msg = match(line, '^([^=]+)=([^=]+)=(.+)$')
        errno[#errno + 1] = {
            name = name,
            num = tonumber(num),
            msg = msg,
        }
    end
    sort(errno, function(a, b)
        return a.num < b.num
    end)
end

-- generate lua file
do
    local f = assert(open('tmpl/errno.lua'))
    local tmpl = assert(f:read('*a'))
    local name = {}
    local code = {}
    for _, v in ipairs(errno) do
        name[#name + 1] = format('_M.%s = new_error_type(%q, %d, %q)', v.name,
                                 v.name, v.num, v.msg)
        code[#code + 1] = format('_M[%d] = _M.%s -- %q', v.num, v.name, v.msg)
    end

    local src = gsub(tmpl, '%${([^}]+)}', {
        ERRNO_NAME = concat(name, '\n'),
        ERRNO_CODE = concat(code, '\n'),
    })

    f = assert(open('errno.lua', 'w+'))
    f:write(src)
    f:close()
end
