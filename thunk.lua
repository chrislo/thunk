-- Thunk
-- 0.0.1 @chrislo
--

engine.name = 'Timber'
local Timber = include("timber/lib/timber_engine")

function init()
  Timber.add_params()
  Timber.add_sample_params(0)

  Timber.options.PLAY_MODE_BUFFER_DEFAULT = 3
  Timber.load_sample(0, "/home/we/dust/audio/common/909/909-BD.wav")

  clock_id = clock.run(step)
end

pattern = {
  pos = 0,
  length = 16,
  data = {1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,1}
}

tick = 0

function step()
  while true do
    clock.sync(1/4)
    pattern.pos = pattern.pos + 1
    if pattern.pos > pattern.length then pattern.pos = 1 end
    if pattern.data[pattern.pos] > 0 then
      engine.noteOn(1, 440, 127, 0)
    end
  end
end

function key(n, z)
  if n == 3 and z == 1 then
    clock.cancel(clock_id)
  end
end
