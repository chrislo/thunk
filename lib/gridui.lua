G = {}

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

local function draw_track_steps(connection, pattern, track, page)
  for i, step in ipairs(Pattern.stepsForSelectedTrack(pattern, track)) do
    if math.ceil(i / 16) == page then
      local pos = pattern_position_to_grid(i - ((page - 1) * 16))

      if step.current then connection:led(pos.x, pos.y, 5) end
      if step.active then connection:led(pos.x, pos.y, 15) end
    end
  end
end

local function draw_track_select(connection, pattern, selected_track)
  for i, step in ipairs(Pattern.currentlyPlayingSteps(pattern)) do
    if selected_track == i then
      connection:led(i+2, 8, 15)
    elseif step.active then
      connection:led(i+2, 8, 10)
    else
      connection:led(i+2, 8, 1)
    end
  end
end

local function draw_page_select(connection, selected_track, selected_page, track)
  local page_for_current_track = selected_page[selected_track]
  local number_of_pages = math.ceil(track.length / 16)

  for i = 1, number_of_pages do
    connection:led(i + 4, 3, 5)
  end

  connection:led(page_for_current_track + 4, 3, 15)
end

function G.redraw(connection, state)
  connection:all(0)
  draw_track_steps(connection, state.pattern, state.selected_track, state.selected_page[state.selected_track])
  draw_track_select(connection, state.pattern, state.selected_track)
  draw_page_select(connection, state.selected_track, state.selected_page, state.pattern.tracks[state.selected_track])
  connection:refresh()
  state.grid_dirty = false
end


return G
