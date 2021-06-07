-- Thunk
-- 0.0.1 @chrislo
--

engine.name = 'Thunk'

local grid = include "midigrid/lib/midigrid"
local UI = require "ui"

Pattern = include("lib/pattern")
Track = include("lib/track")
Step = include("lib/step")
GridUI = include("lib/gridui")
ScreenUI = include("lib/screenui")
Controller = include("lib/controller")
SamplePool = include("lib/sample_pool")
State = include("lib/state")

local screen_refresh_metro
local screen_dirty = true
local main_menu
local press_counter = {}

PPQN = 48

local g = grid.connect()

local state = State:new()

function init()
  state:init()

  params:add_number("swing", "swing", 0, math.floor(PPQN/4), 0, {}, false)
  params:set_action("swing", set_swing)

  clock_id = clock.run(step)

  clock.run(grid_redraw_clock)

  -- ui
  main_menu = UI.ScrollingList.new(0, 0, 1, {})
  main_menu.entries = ScreenUI.menu_entries(state)

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
      engine.note_on(1, state.trigger_immediately, 100)
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
  if n == 2 then
    main_menu:set_index_delta(util.clamp(delta, -1, 1))
  end

  if n == 3 then
    local selected_menu_entry = ScreenUI.menu_entries(state)[main_menu.index]
    selected_menu_entry.handler(delta)
  end

  state.screen_dirty = true
end

function redraw()
  screen.clear()
  main_menu.entries = ScreenUI.menu_labels(state)
  main_menu:redraw()
  screen.update()
end
