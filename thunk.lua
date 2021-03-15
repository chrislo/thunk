-- Thunk
-- 0.0.1 @chrislo
--

engine.name = 'Timber'
local Timber = include("timber/lib/timber_engine")

function init()
  Timber.add_params()
  Timber.add_sample_params(0)
  Timber.load_sample(0, "/home/we/dust/audio/common/909/909-BD.wav")
end

function key(n, z)
  params:set("play_mode_0", 4)

  if n == 2 then
     if z == 1 then
	engine.noteOn(1, 440, 127, 0)
     end
     if z == 0 then
	engine.noteOff(1)
     end
  end
end
