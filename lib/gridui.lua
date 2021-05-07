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

local function draw_track_steps(connection, pattern, track, page)
  for i, step in ipairs(Pattern.stepsForSelectedTrack(pattern, track)) do
    if math.ceil(i / 16) == page then
      local pos = pattern_position_to_grid(i - ((page - 1) * 16))

      if step.current then connection:led(pos.x, pos.y, 5) end
      if step.active then connection:led(pos.x, pos.y, 15) end
    end
  end
end

local function draw_samples(connection, state)
  local sample_idx_start = 1
  local sample_idx_end = 16
  local default_sample_for_current_track = Pattern.track(state.pattern, state.selected_track).default_sample_id

  for i=1, 16 do
    sample_id = i + ((state.selected_bank - 1) * 16)
    if state.sample_pool:has_sample(sample_id) then
      local pos = pattern_position_to_grid(i)
      if sample_id == state.selected_sample then
        connection:led(pos.x, pos.y, 15)
      elseif sample_id == default_sample_for_current_track then
        connection:led(pos.x, pos.y, 10)
      else
        connection:led(pos.x, pos.y, 5)
      end
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

local function draw_bank_select(connection, state)
  for i = 1, 4 do
    connection:led(i + 4, 3, 5)
  end

  connection:led(state.selected_bank + 4, 3, 15)
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

function draw_edit_mode(connection, edit_mode)
  if edit_mode == 'track' then
    connection:led(1, 3, 15)
    connection:led(2, 3, 0)
  elseif edit_mode == 'sample' then
    connection:led(1, 3, 0)
    connection:led(2, 3, 15)
  end
end

function GridUI.redraw(connection, state)
  connection:all(0)
  if state.edit_mode == 'sample' then
    draw_samples(connection, state)
    draw_bank_select(connection, state)
  else
    draw_track_steps(connection, state.pattern, state.selected_track, state.selected_page[state.selected_track])
    draw_page_select(connection, state.selected_track, state.selected_page, state.pattern.tracks[state.selected_track])
  end
  draw_track_select(connection, state.pattern, state.selected_track)
  draw_shift(connection, state.shift)
  draw_playing(connection, state.playing)
  draw_edit_mode(connection, state.edit_mode)
  connection:refresh()
  state.grid_dirty = false
end

return GridUI
