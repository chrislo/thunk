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
GridUI = include("lib/gridui")

local screen_refresh_metro
local screen_dirty = true
local swing_dial
local tempo_dial
local PPQN = 48

local g = grid.connect()
local pattern = Pattern.new(PPQN)
pattern = Pattern.toggleStep(pattern, 1, 1)

local selected_track = 1

function init()
  Timber.add_params()

  for i = 1, 6 do
    Timber.add_sample_params(i)
  end

  Timber.options.PLAY_MODE_BUFFER_DEFAULT = 3
  Timber.load_sample(1, "/home/we/dust/audio/common/808/808-BD.wav")
  Timber.load_sample(2, "/home/we/dust/audio/common/808/808-CP.wav")
  Timber.load_sample(3, "/home/we/dust/audio/common/808/808-CH.wav")
  Timber.load_sample(4, "/home/we/dust/audio/common/808/808-OH.wav")
  Timber.load_sample(5, "/home/we/dust/audio/common/808/808-LT.wav")
  Timber.load_sample(6, "/home/we/dust/audio/common/808/808-HT.wav")

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
      GridUI.redraw(g, pattern, selected_track)
      grid_dirty = false
    end
  end
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
      pattern = Pattern.toggleStep(pattern, x, selected_track)
      grid_dirty = true
    end
    if y==2 then
      pattern = Pattern.toggleStep(pattern, x+8, selected_track)
      grid_dirty = true
    end
    if y==8 and x>=3 then
      selected_track = x-2
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
