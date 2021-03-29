-- Thunk
-- 0.0.1 @chrislo
--

engine.name = 'Timber'

local Timber = include("timber/lib/timber_engine")
local grid = include "midigrid/lib/midigrid"
local UI = require "ui"

Pattern = include("lib/pattern")
Track = include("lib/track")
Step = include("lib/step")

local screen_refresh_metro
local screen_dirty = true
local swing_dial
local tempo_dial
local PPQN = 48

local g = grid.connect()
local pattern = Pattern.new(PPQN)
pattern = Pattern.toggleStep(pattern, 1)
pattern = Pattern.offsetAllEvenSteps(pattern, 4)

function init()
  Timber.add_params()

  for i = 0, 5 do
    Timber.add_sample_params(i)
  end

  Timber.options.PLAY_MODE_BUFFER_DEFAULT = 3
  Timber.load_sample(0, "/home/we/dust/audio/common/808/808-BD.wav")
  Timber.load_sample(1, "/home/we/dust/audio/common/808/808-CP.wav")
  Timber.load_sample(2, "/home/we/dust/audio/common/808/808-CH.wav")
  Timber.load_sample(3, "/home/we/dust/audio/common/808/808-OH.wav")
  Timber.load_sample(4, "/home/we/dust/audio/common/808/808-LT.wav")
  Timber.load_sample(5, "/home/we/dust/audio/common/808/808-HT.wav")

  params:add_number("swing", "swing", 0, math.floor(PPQN/4), false, 0)
  params:set_action("swing", set_swing)

  clock_id = clock.run(step)

  grid_dirty = true
  clock.run(grid_redraw_clock)

  -- ui
  swing_dial = UI.Dial.new(5, 5, 25, params:get("swing"), 0, math.floor(PPQN/4), 1)
  tempo_dial = UI.Dial.new(35, 5, 25, params:get("clock_tempo"), 40, 240, 1)

  screen_refresh_metro = metro.init()
  screen_refresh_metro.event = function()
    if screen_dirty then
      screen_dirty = false
      redraw()
    end
  end
  screen_refresh_metro:start(1 / 15)
end

function set_swing(i)
  pattern = Pattern.offsetAllEvenSteps(pattern, i)
end

function grid_redraw_clock()
  while true do
    clock.sleep(1/30)
    if grid_dirty then
      grid_redraw()
      grid_dirty = false
    end
  end
end

function pattern_position_to_grid(i)
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

function draw_track_steps()
  for i, step in ipairs(Pattern.stepsForSelectedTrack(pattern)) do
    local pos = pattern_position_to_grid(i)

    if step.current then g:led(pos.x, pos.y, 5) end
    if step.active then g:led(pos.x, pos.y, 15) end
  end
end

function draw_track_select()
  for i, step in ipairs(Pattern.currentlyPlayingSteps(pattern)) do
    if pattern.selectedTrack == i then
      g:led(i+2, 8, 15)
    elseif step.active then
      g:led(i+2, 8, 10)
    else
      g:led(i+2, 8, 1)
    end
  end
end

function grid_redraw()
  g:all(0)
  draw_track_steps()
  draw_track_select()
  g:refresh()
end

function step()
  while true do
    clock.sync(1/PPQN)
    pattern = Pattern.advance(pattern)
    Pattern.playSteps(pattern, engine)
    grid_dirty = true
  end
end

function g.key(x,y,z)
  if z==1 then
    if y==1 then
      pattern = Pattern.toggleStep(pattern, x)
      grid_dirty = true
    end
    if y==2 then
      pattern = Pattern.toggleStep(pattern, x+8)
      grid_dirty = true
    end
    if y==8 and x>=3 then
      pattern.selectedTrack = x-2
    end
  end
end

function enc(n, delta)
  if n == 2 then
    params:delta("swing", delta)
    swing_dial:set_value_delta(delta)
  end

  if n == 3 then
    params:delta("clock_tempo", delta)
    tempo_dial:set_value_delta(delta)
  end

  screen_dirty = true
end

function redraw()
  screen.clear()
  swing_dial:redraw()
  tempo_dial:redraw()
  screen.update()
end
