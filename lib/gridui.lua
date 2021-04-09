G = {}

function G.draw(connection, pattern, selected_track)
  connection:all(0)
  draw_track_steps(connection, pattern, selected_track)
  draw_track_select(connection, pattern, selected_track)
  connection:refresh()
end

local function draw_track_steps(connection, pattern, selected_track)
  for i, step in ipairs(Pattern.stepsForSelectedTrack(pattern, selected_track)) do
    local pos = pattern_position_to_grid(i)

    if step.current then connection:led(pos.x, pos.y, 5) end
    if step.active then connection:led(pos.x, pos.y, 15) end
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

return G
