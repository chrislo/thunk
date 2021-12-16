-- Thunk
-- 0.0.1 @chrislo
--

engine.name = 'Thunk'

PPQN = 48

UI = require "ui"
fileselect = require "fileselect"
Pattern = include("lib/pattern")
Track = include("lib/track")
Step = include("lib/step")
GridUI = include("lib/gridui")
Controller = include("lib/controller")
SamplePool = include("lib/sample_pool")
StateMachine = include("lib/statemachine")
Menu = include("lib/menu")
State = include("lib/state")

local screen_refresh_metro
local press_counter = {}
local grid = util.file_exists(_path.code.."midigrid") and include "midigrid/lib/midigrid" or grid
local g = grid.connect()
local state = State:new(engine)

function init()
  init_params()
  state:init()

  clock.run(step)
  clock.run(grid_redraw_clock)

  screen_refresh_metro = metro.init()
  screen_refresh_metro.event = function()
    if state.screen_dirty then
      state.screen_dirty = false
      redraw()
    end
  end
  screen_refresh_metro:start(1 / 5)

  for x = 1, 16 do
    press_counter[x] = {}
  end
end

function init_params()
  params:add_group("Global", 5)

  params:add_number("swing", "swing", 0, math.floor(PPQN/4), 0)
  params:set_action("swing", set_swing)

  params:add_control("reverb_room", "reverb room", controlspec.AMP)
  params:set_action("reverb_room", function(x) engine.reverb_room(x) end)

  params:add_control("reverb_damp", "reverb damp", controlspec.AMP)
  params:set_action("reverb_damp", function(x) engine.reverb_damp(x) end)

  params:add_control("delay_time", "delay time", controlspec.DELAY)
  params:set_action("delay_time", function(x) engine.delay_time(x) end)

  params:add_control("decay_time", "decay time", controlspec.DELAY)
  params:set_action("decay_time", function(x) engine.decay_time(x) end)

  for i = 1,6 do
    params:add_group("Track" .. i, 10)
    name = "t" .. i .. "_volume"
    params:add_control(name, "volume", controlspec.AMP)
    params:set_action(name, function(x) engine.volume(i, x) end)
    params:set(name, params:get_range(name)[2]) -- set to max

    name = "t" .. i .. "_cutoff"
    params:add_control(name, "cutoff", controlspec.WIDEFREQ)
    params:set_action(name, function(x) engine.cutoff(i, x) end)
    params:set(name, params:get_range(name)[2]) -- set to max

    name = "t" .. i .. "_resonance"
    params:add_control(name, "resonance", controlspec.AMP)
    params:set_action(name, function(x) engine.resonance(i, x) end)

    name = "t" .. i .. "_sample_start"
    params:add_control(name, "sample_start", controlspec.AMP)
    params:set_action(name, function(x) state:set_track_sample_start(i, x) end)
    params:set(name, params:get_range(name)[1]) -- set to min

    name = "t" .. i .. "_sample_end"
    params:add_control(name, "sample_end", controlspec.AMP)
    params:set_action(name, function(x) state:set_track_sample_end(i, x) end)
    params:set(name, params:get_range(name)[2]) -- set to max

    name = "t" .. i .. "_attack"
    params:add_control(name, "attack", controlspec.AMP)
    params:set_action(name, function(x) engine.attack(i, x) end)

    name = "t" .. i .. "_release"
    params:add_control(name, "release", controlspec.AMP)
    params:set_action(name, function(x) engine.release(i, x) end)

    name = "t" .. i .. "_reverb_send"
    params:add_control(name, "reverb send", controlspec.AMP)
    params:set_action(name, function(x) engine.reverb_send(i, x) end)

    name = "t" .. i .. "_delay_send"
    params:add_control(name, "delay send", controlspec.AMP)
    params:set_action(name, function(x) engine.delay_send(i, x) end)

    name = "t" .. i .. "_probability"
    params:add_control(name, "probability", controlspec.AMP)
    params:set_action(name, function(x) state:set_track_probability(i, x) end)
  end

  params:add_group("Samples", 64)
  for i = 1,64 do
    name = "sample_" .. i
    params:add_file(name, "Sample " .. i)
    params:set_action(name, function(file) state.sample_pool:add(file, i) end)
  end
end

function set_swing(swing)
  state.pattern:setSwing(swing)
end

function grid_redraw_clock()
  while true do
    clock.sleep(1/30)
    if state.grid_dirty then
      GridUI.redraw(g, state)
    end
  end
end

function step()
  while true do
    clock.sync(1/PPQN)
    if state.playing then
      state.pattern:advance()
      state.pattern:playSteps(engine)
      state.grid_dirty = true
    end

    if state.trigger_immediately then
      engine.note_on(1, state.trigger_immediately, 0.8, 1, 0, 1, 0)
      state.trigger_immediately = nil
    end
  end
end

function g.key(x,y,z)
  if z==1 then
    press_counter[x][y] = clock.run(long_press, x, y)
  elseif z==0 then
    if press_counter[x][y] then
      clock.cancel(press_counter[x][y])
      short_press(x,y)
    else
      long_release(x,y)
    end
  end
end

function short_press(x,y)
  Controller.handle_short_press(state, x, y)
end

function long_press(x,y)
  clock.sleep(0.25)
  Controller.handle_long_press(state, x, y)
  press_counter[x][y] = nil
end

function long_release(x,y)
  Controller.handle_long_release(state, x, y)
end

function key(n,z)
  Controller.handle_key(state, n, z)
end

function enc(n, delta)
  Controller.handle_enc(state, n, delta)
end

function redraw()
  screen.clear()
  state.menu:draw(state)
  screen.update()
end
