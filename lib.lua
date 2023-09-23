local from_cmd = function(cmd)
  local fz = io.popen(cmd)
  if fz then
    local out = fz:read('*a')
    local _, _, status = fz:close()
    if status == 0 then
      return out
    end
  end
end

local parse_kp = function(line)
  local i, j = line:find('%s*=%s*')
  local key = line:sub(1, i - 1):gsub('^%s*', '')
  local val = line:sub(j + 1, line:len()):gsub('%s*$', '')
  return key, val
end

local section_to_pattern = function(selector)
  local r = ''
  for c in selector:gmatch('.') do
    if c == '*' then
      r = r .. '[^/]'
    elseif c == '.' then
      r = r .. '%.'
    else
      r = r .. c
    end
  end
  return r
end

local parse_file = function(path)
  local config = {}
  for line in io.open(path):lines() do
    if line:match('^%s*[^[;#][^=]*=') then -- key-value pair
      local key, val = parse_kp(line)
      if #config == 0 and key == 'root' then
        config.root = val == 'true'
      else
        config[#config].pairs[key] = val
      end
    elseif line:match('^%s*%[.*%]%s*$') then -- section
      config[#config + 1] = {
        ['pairs'] = {},
        pattern = section_to_pattern(
          line:gsub('^%s*%[', ''):gsub('%]%s*$', '')
        ),
      }
    elseif not line:match('^%s*$') and not line:match('^%s*[#;]') then
      print(path .. ': invalid line: ' .. line)
    end
  end
  for i = 1, #config // 2, 1 do
    config[i], config[#config - i + 1] = config[#config - i + 1], config[i]
  end
  return config
end

local get_config_files = function(path)
  local config_files =
    from_cmd("set -- '" .. path:gsub("'", "\\'") .. "'; " .. [[
      while [ "$1" != / ]; do
        cd "$(dirname "$1")"
        set -- "$PWD"
        ! [ -e .editorconfig ] || printf "%s/.editorconfig\0" "$1"
      done
    ]])
  return string.gmatch(config_files, '%Z+')
end

local configs = {}
local get_configs_for = function(path)
  local specific_configs = {}
  for path in get_config_files(path) do
    if configs[path] == nil then
      configs[path] = parse_file(path)
    end
    table.insert(specific_configs, configs[path])
  end
  return specific_configs
end

local get_sections_for = function(configs, path)
  local sections = {}
  for _, config in pairs(configs) do
    for _, section in ipairs(config) do
      print('selector: ' .. section.pattern)
      if path:match(section.pattern) then
        print('path: ' .. path .. ' matches ' .. section.pattern)
        table.insert(sections, section)
      end
    end
    if config.root then
      break
    end
  end
  return sections
end

local get_pairs = function(sections)
  local all_pairs = {}
  for _, section in ipairs(sections) do
    for key, val in pairs(section.pairs) do
      if all_pairs[key] == nil then
        all_pairs[key] = val ~= 'unset' and val or nil
        print(key .. ' = ' .. val)
      end
    end
  end
  return all_pairs
end

return function(path)
  return get_pairs(get_sections_for(get_configs_for(path), path))
end
