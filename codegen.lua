local concat = table.concat
local sort = table.sort
local format = string.format
local gsub = string.gsub
local execute = os.execute
local exec = require('exec').execvp
local split = require('stringex').split
local trim_space = require('stringex').trim_space

-- get compiler
local CC
for _, v in ipairs({
    'gcc',
    'clang',
}) do
    local cmd = assert(exec('which', {
        v,
    }))
    cmd:waitpid()
    local out = cmd.stdout:read('*a')
    local err = cmd.stderr:read('*a')
    if #err > 0 then
        print(format('%q not found: ', v, err))
    elseif #out > 0 then
        CC = trim_space(out)
        print(format('found %q', CC))
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
    local f = assert(io.open('var/errno.txt'))

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
    f = assert(io.open('var/errno.c', 'w+'))
    assert(f:write(src))
    f:close()
end

-- compile src file
do
    local cmd = assert(exec(CC, {
        'var/errno.c',
        '-o',
        'var/errno.out',
    }))
    cmd:waitpid()
    local err = cmd.stderr:read('*a')
    assert(#err == 0, err)
end

-- extract errno
local errno = {}
do
    local cmd = assert(exec('var/errno.out'))
    cmd:waitpid()
    local err = cmd.stderr:read('*a')
    assert(#err == 0, err)

    for line in cmd.stdout:lines() do
        local arr = split(line, '=', true, 3)
        errno[#errno + 1] = {
            name = arr[1],
            num = tonumber(arr[2]),
            msg = arr[3],
        }
    end
    sort(errno, function(a, b)
        return a.num < b.num
    end)
end

-- generate lua file
do
    local f = assert(io.open('tmpl/errno.lua'))
    local tmpl = assert(f:read('*a'))
    local name = {}
    local code = {}
    for _, v in ipairs(errno) do
        name[#name + 1] = format('_M.%s = new(%q, %s, %q)', v.name, v.name,
                                 v.num, v.msg)
        code[#code + 1] = format('_M[%d] = _M.%s -- %q', v.num, v.name, v.msg)
    end

    local src = gsub(tmpl, '%${([^}]+)}', {
        ERRNO_NAME = concat(name, '\n'),
        ERRNO_CODE = concat(code, '\n'),
    })

    f = assert(io.open('errno.lua', 'w+'))
    f:write(src)
    f:close()
end
