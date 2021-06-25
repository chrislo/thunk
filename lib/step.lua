Step = {}

function Step:new()
  obj = {
    active = false,
    current = false,
    offset = 0,
    velocity = 127,
    sample_id = nil
  }

  setmetatable(obj, self)
  self.__index = self
  return obj
end

local function clamp(n, min, max)
  return math.min(max,(math.max(n,min)))
end

function Step:delta_offset(delta)
  self.offset = clamp(self.offset + delta, 0, PPQN/4)
end

function Step:delta_velocity(delta)
  self.velocity = clamp(self.velocity + delta, 0, 127)
end

function Step:delta_sample_id(default, delta)
  local sample_id
  if self.sample_id then
    sample_id = self.sample_id
  else
    sample_id = default
  end

  self.sample_id = clamp(sample_id + delta, 1, 64)
end

function Step:sample_name(state)
  if self.sample_id then
    return state.sample_pool:name(self.sample_id)
  else
    return '<default>'
  end
end

return Step
