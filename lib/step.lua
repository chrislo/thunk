Step = {}

function Step:new(track)
  obj = {
    active = false,
    current = false,
    offset = 0,
    velocity = 127,
    sample_id = nil,
    track = track
  }

  setmetatable(obj, self)
  self.__index = self
  return obj
end

local function clamp(n, min, max)
  return math.min(max,(math.max(n,min)))
end

function Step:toggle()
  if self.active then
    self.active = false
    self:reset_locks()
  else
    self.active = true
  end
end

function Step:reset_locks()
  self.offset = 0
  self.velocity = 127
  self.sample_id = nil
end

function Step:delta_offset(delta)
  self.offset = clamp(self.offset + delta, 0, PPQN/4)
end

function Step:delta_velocity(delta)
  self.velocity = clamp(self.velocity + delta, 0, 127)
end

function Step:delta_sample_id(delta)
  local sample_id
  if self.sample_id then
    sample_id = self.sample_id
  else
    sample_id = self.track.default_sample_id
  end

  self.sample_id = clamp(sample_id + delta, 1, 64)
end

function Step:sample_name(state)
  if self.sample_id then
    return state.sample_pool:name(self.sample_id)
  else
    return state.sample_pool:name(self.track.default_sample_id)
  end
end

return Step
