local core = dofile(
  (debug.getinfo(1, 'S').source:sub(2):match('(.*/)') or '') .. 'core.lua'
)

local test = function(section, path)
  if core.section_to_pattern(section)(path) == nil then
    error(section .. ' does not match ' .. path)
  end
end

test('eh', 'eh')
test('eh.h', '/b/eh.h')
test('eh.*', '/b/eh.c')
test('*', '/b/eh.c')
test('*.h', '/hmmm/eh.h')
