Step = {}

function Step:new(track)
  obj = {
    active = false,
    current = false,
    offset = 0,
    velocity = 127,
    transpose = nil,
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
    self:set_defaults()
  else
    self.active = true
  end
end

function Step:set_defaults()
  self.offset = 0
  self.velocity = 127
  self.sample_id = nil
  self.transpose = nil
end

function Step:delta_offset(delta)
  self.offset = clamp(self.offset + delta, 0, PPQN/4)
end

function Step:delta_velocity(delta)
  self.velocity = clamp(self.velocity + delta, 0, 127)
end

function Step:delta_transpose(delta)
  self.transpose = clamp(self:transpose_or_default() + delta, -24, 24)
end

function Step:delta_sample_id(delta)
  self.sample_id = clamp(self:sample_id_or_default() + delta, 1, 64)
end

function Step:sample_id_or_default()
  if self.sample_id then
    return self.sample_id
  else
    return self.track.default_sample_id
  end
end

function Step:transpose_or_default()
  if self.transpose then
    return self.transpose
  else
    return self.track.transpose
  end
end

function Step:play(track_id, engine)
  if not self.active then
    return
  end

  local rate = 2^(self:transpose_or_default() / 12)

  engine.note_on(track_id, self:sample_id_or_default(), self.velocity / 127, rate)
end

function Step:sample_name(state)
  if self.sample_id then
    return state.sample_pool:name(self.sample_id)
  else
    return state.sample_pool:name(self.track.default_sample_id)
  end
end

return Step
