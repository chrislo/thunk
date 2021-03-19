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

function step()
  while true do
    clock.sync(1)
    engine.noteOn(1, 440, 127, 0)
  end
end

function key(n, z)
  if n == 3 and z == 1 then
    clock.cancel(clock_id)
  end
end
