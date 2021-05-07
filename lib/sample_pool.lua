SamplePool = {}

function SamplePool:new()
  samples = {}
  for i=1,64 do
    samples[i] = {}
  end

  obj = {
    samples = samples
  }

  setmetatable(obj, self)
  self.__index = self
  return obj
end

function SamplePool:add(fn, idx)
  self.samples[idx] = { fn = fn }
  Timber.load_sample(idx, fn)
end

function SamplePool:add_dir(dir)
  files = util.scandir(dir)

  for idx, fn in pairs(files) do
    self:add(dir .. fn, idx)
  end
end

function SamplePool:has_sample(idx)
  return self.samples[idx].fn ~= nil
end

function SamplePool:name(idx)
  return self.samples[idx].fn:match("^.+/(.+)$")
end

function SamplePool:init()
  Timber.add_params()

  for idx, _ in pairs(self.samples) do
    Timber.add_sample_params(idx)
  end

  Timber.options.PLAY_MODE_BUFFER_DEFAULT = 3
end

return SamplePool
