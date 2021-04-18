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
ScreenUI = include("lib/screenui")

local screen_refresh_metro
local screen_dirty = true
local main_menu
local PPQN = 48

local g = grid.connect()
local pattern = Pattern.new(PPQN)
pattern = Pattern.toggleStep(pattern, 1, 1)

local selected_track = 1
local selected_page = {1, 1, 1, 1, 1, 1}

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

  params:add_number("swing", "swing", 0, math.floor(PPQN/4), 0, {}, false)
  params:set_action("swing", set_swing)

  clock_id = clock.run(step)

  grid_dirty = true
  clock.run(grid_redraw_clock)

  -- ui
  main_menu = UI.ScrollingList.new(0, 0, 1, {})
  main_menu.entries = ScreenUI.menu_entries()

  screen_refresh_metro = metro.init()
  screen_refresh_metro.event = function()
    if screen_dirty then
      screen_dirty = false
      redraw()
    end
  end
  screen_refresh_metro:start(1 / 5)
end

function set_swing(swing)
  pattern = Pattern.setSwing(pattern, swing)
end

function grid_redraw_clock()
  while true do
    clock.sleep(1/30)
    if grid_dirty then
      GridUI.redraw(g, pattern, selected_track, selected_page)
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
      local step_to_toggle = x + ((selected_page[selected_track] - 1) * 16)
      pattern = Pattern.toggleStep(pattern, step_to_toggle, selected_track)
      grid_dirty = true
    end
    if y==2 then
      local step_to_toggle = x + ((selected_page[selected_track] - 1) * 16) + 8
      pattern = Pattern.toggleStep(pattern, step_to_toggle, selected_track)
      grid_dirty = true
    end
    if y==3 and x>=5 then
      local page = x - 4
      selected_page[selected_track] = page
      pattern = Pattern.maybeCreatePage(pattern, selected_track, page)
    end
    if y==8 and x>=3 then
      selected_track = x-2
    end
  end
end

function enc(n, delta)
  if n == 2 then
    main_menu:set_index_delta(util.clamp(delta, -1, 1))
  end

  if n == 3 then
    if main_menu.index == 1 then
      params:delta("clock_tempo", delta)
      main_menu.entries = ScreenUI.menu_entries()
    end
    if main_menu.index == 2 then
      params:delta("swing", delta)
      main_menu.entries = ScreenUI.menu_entries()
    end
  end

  screen_dirty = true
end

function redraw()
  screen.clear()
  main_menu:redraw()
  screen.update()
end
