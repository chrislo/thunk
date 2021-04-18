S = {}

local function format_menu_item(key, value)
  local max_width = 30
  local spaces_to_insert = max_width - string.len(key) - string.len(value)

  return key .. string.rep(" ", spaces_to_insert) .. value
end

local function swing_as_percentage(pulses)
  return math.floor(50 + pulses * (50 / (PPQN/4))) .. "%"
end

function S.menu_entries()
  local entries = {
    format_menu_item("tempo", params:get("clock_tempo")),
    format_menu_item("swing", swing_as_percentage(params:get("swing")))
  }

  return entries
end

return S
