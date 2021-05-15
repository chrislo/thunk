Track = {}

function Track:new(ppqn, default_sample_id)
  local steps = {}
  for i = 1, 64 do
    steps[i] = Step:new()
  end

  track = {
    ppqn = ppqn or 4,
    tick = 0,
    pos = 1,
    length = 16,
    steps = steps,
    swing = 0,
    default_sample_id = default_sample_id,
    mute = false
  }

  track.steps[track.pos].current = true

  setmetatable(track, self)
  self.__index = self

  return track
end

local function pulses_per_step(track)
  return math.floor(track.ppqn / 4)
end

local function offset_in_current_step(track)
  return track.tick % pulses_per_step(track)
end

local function advance_step(track)
  return offset_in_current_step(track) == 0
end

function Track:advance()
  self.steps[self.pos].current = false
  self.tick = self.tick + 1

  if advance_step(self) then
    self.pos = self.pos + 1
  end

  if self.pos > self.length then
    self.pos = 1
  end

  self.steps[self.pos].current = true
end

function Track:reset()
  self.pos = 1
end

function Track:toggleStep(step)
  self.steps[step].active = not self.steps[step].active
end

function Track:setSwing(swing)
  self.swing = swing
end

function Track:playStep(engine, id)
  if self.mute then
    return
  end

  local step = self.steps[self.pos]

  local swing_offset = 0
  if self.pos % 2 == 0 then
    swing_offset = self.swing
  end

  local sample_id = nil
  if step.sample_id then
    sample_id = step.sample_id
  else
    sample_id = self.default_sample_id
  end

  if step.active and (offset_in_current_step(self) == (step.offset + swing_offset)) then
    engine.noteOn(id, 440, step.velocity / 127, sample_id)
  end
end

function Track:currentlyPlayingStep()
  return self.steps[self.pos]
end

function Track:maybeCreatePage(page)
  local number_of_pages = math.ceil(self.length / 16)

  if page > number_of_pages then
    self.length = 16 * page
  end
end

local function clamp(n, min, max)
  return math.min(max,(math.max(n,min)))
end

function Track:delta_default_sample_id(delta)
  self.default_sample_id = clamp(self.default_sample_id + delta, 1, 256)
end

return Track
