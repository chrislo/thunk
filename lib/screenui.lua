ScreenUI = {}

local function format_menu_item(key, value)
  local v
  if type(value) == 'number' then
    v = string.format("%.2f", value)
  else
    v = tostring(value)
  end
  local max_width = 30
  local spaces_to_insert = max_width - string.len(key) - string.len(v) - 1

  return key .. string.rep(" ", spaces_to_insert) .. v
end

local function swing_as_percentage(pulses)
  return math.floor(50 + pulses * (50 / (PPQN/4))) .. "%"
end

function ScreenUI.menu_labels(state)
  labels = {}

  for _, entry in ipairs(ScreenUI.menu_entries(state)) do
    table.insert(labels, entry.label)
  end

  return labels
end

function ScreenUI.menu_entries(state)
  local entries = {}

  if state.edit_mode == 'step' then
    local steps = state.pattern:stepsForSelectedTrack(state.selected_track)
    local step = steps[state.selected_step]
    local track = state.pattern:track(state.selected_track)

    local sample_id = nil
    if step.sample_id then
      sample_id = step.sample_id
    else
      sample_id = track.default_sample_id
    end

    table.insert(entries, {
        label = format_menu_item("sample", state.sample_pool:name(sample_id)),
        handler = function(x) step:delta_sample_id(track.default_sample_id, x) end
    })

    table.insert(entries, {
        label = format_menu_item("offset", step.offset),
        handler = function(x) step:delta_offset(x) end
    })

    table.insert(entries, {
        label = format_menu_item("velocity", step.velocity),
        handler = function(x) step:delta_velocity(x) end
    })
  elseif state.edit_mode == 'track' then
    local track = state.pattern:track(state.selected_track)
    local sample_id = track.default_sample_id

    table.insert(entries, {
        label = format_menu_item("sample", state.sample_pool:name(sample_id)),
        handler = function(x) track:delta_default_sample_id(x) end
    })

  elseif state.edit_mode == 'pattern' then
    table.insert(entries, {
        label = format_menu_item("tempo", params:get("clock_tempo")),
        handler = function(x) params:delta("clock_tempo", x) end
    })

    table.insert(entries, {
        label = format_menu_item("swing", swing_as_percentage(params:get("swing"))),
        handler = function(x) params:delta("swing", x) end
    })

    table.insert(entries, {
        label = "manage samples",
        handler = function(x) state.edit_mode = "samples" end
    })

  elseif state.edit_mode == 'samples' then
    for i, v in ipairs(state.sample_pool.samples) do
      table.insert(entries, {
          label = state.sample_pool:name(i),
          handler = function(i) end
      })
    end
  end

  return entries
end

return ScreenUI
