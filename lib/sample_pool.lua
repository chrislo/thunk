SamplePool = {}

function SamplePool:new(engine)
  samples = {}
  for i=1,256 do
    samples[i] = {}
  end

  obj = {
    samples = samples,
    engine = engine
  }

  setmetatable(obj, self)
  self.__index = self
  return obj
end

function SamplePool:add(fn, idx)
  self.samples[idx] = { fn = fn }
  self.engine.load_sample(idx, fn)
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
  if self:has_sample(idx) then
    return self.samples[idx].fn:match("^.+/(.+)$")
  else
    return "<empty>"
  end
end

return SamplePool
