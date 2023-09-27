local core = dofile(
  (debug.getinfo(1, 'S').source:sub(2):match('(.*/)') or '') .. 'core.lua'
)

local test = function(section, path)
  for _, pattern in ipairs(core.section_to_patterns(section)) do
    if path:match(pattern) == nil then
      error(pattern .. ' does not match ' .. path)
    end
  end
end

test('eh', 'eh')
test('eh.h', '/b/eh.h')
test('eh.*', '/b/eh.c')
test('*', '/b/eh.c')
test('*.h', '/hmmm/eh.h')
