-- Thunk
-- 0.0.1 @chrislo
--

engine.name = 'Timber'
local Timber = include("timber/lib/timber_engine")
local grid = include "midigrid/lib/midigrid"
Pattern = include("lib/pattern")
Track = include("lib/track")
Step = include("lib/step")

g = grid.connect()
pattern = Pattern.new()
pattern = Pattern.toggleStep(pattern, 1)

function init()
  Timber.add_params()

  for i = 0, 3 do
    Timber.add_sample_params(i)
  end

  Timber.options.PLAY_MODE_BUFFER_DEFAULT = 3
  Timber.load_sample(0, "/home/we/dust/audio/common/808/808-BD.wav")
  Timber.load_sample(1, "/home/we/dust/audio/common/808/808-CP.wav")
  Timber.load_sample(2, "/home/we/dust/audio/common/808/808-CH.wav")
  Timber.load_sample(3, "/home/we/dust/audio/common/808/808-OH.wav")

  clock_id = clock.run(step)

  grid_dirty = true
  clock.run(grid_redraw_clock)
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

function grid_redraw()
  g:all(0)

  for i, step in ipairs(Pattern.stepsForSelectedTrack(pattern)) do
    local pos = pattern_position_to_grid(i)

    if step.current then g:led(pos.x, pos.y, 5) end
    if step.active then g:led(pos.x, pos.y, 15) end
  end

  g:refresh()
end

function step()
  while true do
    clock.sync(1/4)
    pattern = Pattern.advance(pattern)

    for k,v in ipairs(Pattern.currentSteps(pattern)) do
      if v then
        engine.noteOn(k, 440, 127, k-1)
      end
    end
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
    if y==8 then
      pattern.selectedTrack = x
    end
  end
end

function key(n, z)
  if n == 3 and z == 1 then
    clock.cancel(clock_id)
  end
end
