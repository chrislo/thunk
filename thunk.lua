-- Thunk
-- 0.0.1 @chrislo
--

engine.name = 'Timber'
local Timber = include("timber/lib/timber_engine")

function init()
  Timber.options.PLAY_MODE_BUFFER_DEFAULT = 3
  Timber.add_params()
  Timber.add_sample_params(0)
  Timber.load_sample(0, "/home/we/dust/audio/common/909/909-BD.wav")
end

function play()
  while true do
    clock.sync(1)
    engine.noteOn(1, 440, 127, 0)
  end
end

running = false

function key(n, z)
  params:set("clock_tempo",100)

  if n == 2 and z == 1 then
    if not running then
      clock_id = clock.run(play)
      running = true
    end
  end

  if n == 3 and z == 1 then
    if running then
      clock.cancel(clock_id)
      running = false
    end
  end
end
