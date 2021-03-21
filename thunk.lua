-- Thunk
-- 0.0.1 @chrislo
--

engine.name = 'Timber'
local Timber = include("timber/lib/timber_engine")
local grid = include "midigrid/lib/midigrid"
Pattern = include("lib/pattern")
Track = include("lib/track")

g = grid.connect()
pattern = Pattern.new()
pattern = Pattern.toggleStep(pattern, 1)

function init()
  Timber.add_params()
  Timber.add_sample_params(0)

  Timber.options.PLAY_MODE_BUFFER_DEFAULT = 3
  Timber.load_sample(0, "/home/we/dust/audio/common/909/909-BD.wav")

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

function grid_redraw()
  g:all(0)

  for i=1, 16 do
    if i <= 8 then
      if Pattern.positionOfSelectedTrack(pattern) == i then g:led(i, 1, 5) end
      if Pattern.selectedTrackIsActive(pattern, i) then g:led(i,1,15) end
    else
      if Pattern.positionOfSelectedTrack(pattern) == i then g:led(i-8, 2, 5) end
      if Pattern.selectedTrackIsActive(pattern, i) then g:led(i-8,2,15) end
    end
  end

  g:refresh()
end

function step()
  while true do
    clock.sync(1/4)
    pattern = Pattern.advance(pattern)

    for k,v in ipairs(Pattern.currentSteps(pattern)) do
      if v then
        engine.noteOn(1, 440, 127, k-1)
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
  end
end

function key(n, z)
  if n == 3 and z == 1 then
    clock.cancel(clock_id)
  end
end
