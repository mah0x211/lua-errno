local dofile = dofile

for _, pathname in ipairs({
    'test/errno_test.lua',
    'test/set_get_test.lua',
    'test/strerror_test.lua',
    'test/eai_test.lua',
}) do
    dofile(pathname)
end
