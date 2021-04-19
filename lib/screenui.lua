S = {}

local function format_menu_item(key, value)
  local value = tostring(value)
  local max_width = 30
  local spaces_to_insert = max_width - string.len(key) - string.len(value)

  return key .. string.rep(" ", spaces_to_insert) .. value
end

local function swing_as_percentage(pulses)
  return math.floor(50 + pulses * (50 / (PPQN/4))) .. "%"
end

function S.menu_labels(state)
  labels = {}

  for _, entry in S.menu_entries(state) do
    table.insert(labels, entry.label)
  end
end

function S.menu_entries(state)
  local entries = {}

  if state.selected_step then
    local steps = Pattern.stepsForSelectedTrack(state.pattern, state.selected_track)
    local step = steps[state.selected_step]

    table.insert(entries, {
        label = format_menu_item("offset", step.offset),
        handler = function(x) Step.delta_offset(step, x) end
    })

    table.insert(entries, {
        label = format_menu_item("velocity", step.velocity),
        handler = function(x) Step.delta_velocity(step, x) end
    })
  else
    table.insert(entries, {
        label = format_menu_item("tempo", params:get("clock_tempo")),
        handler = function(x) params:delta("clock_tempo", x) end
    })

    table.insert(entries, {
        label = format_menu_item("swing", swing_as_percentage(params:get("swing"))),
        handler = function(x) params:delta("swing", x) end
    })
  end

  return entries
end

return S
