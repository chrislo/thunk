GridUI = {}

local function pattern_position_to_grid(i)
  local loc = {}

  if i <= 8 then
    loc.x = i
    loc.y = 1
  else
    loc.x = i-8
    loc.y = 2
  end

  return loc
end

local function draw_track_steps(connection, state)
  local page = state:current_page()

  for i, step in ipairs(state:current_steps()) do
    if math.ceil(i / 16) == page then
      local pos = pattern_position_to_grid(i - ((page - 1) * 16))

      if step.current then connection:led(pos.x, pos.y, 5) end
      if step.active then connection:led(pos.x, pos.y, 15) end
    end
  end
end

local function draw_track_select(connection, state)
  for i, step in ipairs(state.pattern:currentlyPlayingSteps()) do
    local track = state.pattern:track(i)

    if track.mute then
      connection:led(i+2, 8, 5)
    elseif state:get_selected_track() == i then
      connection:led(i+2, 8, 15)
    elseif step.active then
      connection:led(i+2, 8, 10)
    else
      connection:led(i+2, 8, 1)
    end
  end
end

local function draw_page_select(connection, state)
  local number_of_pages = math.ceil(state:current_track().length / 16)

  for i = 1, number_of_pages do
    connection:led(i + 4, 3, 5)
  end

  connection:led(state:current_page() + 4, 3, 15)
end

function draw_shift(connection, shift)
  if shift then
    connection:led(1, 8, 15)
  else
    connection:led(1, 8, 0)
  end
end

function draw_playing(connection, playing)
  if playing then
    connection:led(1, 7, 15)
  else
    connection:led(1, 7, 3)
  end
end

function GridUI.redraw(connection, state)
  connection:all(0)
  draw_track_steps(connection, state)
  draw_page_select(connection, state)
  draw_track_select(connection, state)
  draw_shift(connection, state.shift)
  draw_playing(connection, state.playing)
  connection:refresh()
  state.grid_dirty = false
end

return GridUI
