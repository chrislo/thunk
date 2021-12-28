Track = {}

function Track:new(ppqn, default_sample_id)
  track = {
    ppqn = ppqn or 4,
    tick = 0,
    pos = 1,
    length = 16,
    steps = steps,
    swing = 0,
    transpose = 0,
    default_sample_id = default_sample_id,
    mute = false,
    probability = 1,
    sample_start = 0,
    sample_end = 1,
    loop = 0,
    attack = 0.01,
    release = 0.01,
    duration = 0.5,
  }

  setmetatable(track, self)
  self.__index = self

  track.steps = {}
  for i = 1, 64 do
    track.steps[i] = Step:new(track)
  end

  track.steps[track.pos].current = true

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
  self.steps[step]:toggle()
end

function Track:setSwing(swing)
  self.swing = swing
end

function Track:playStep(engine, id)
  if self.mute then
    return
  end

  if math.random() > self.probability then
    return
  end

  local step = self.steps[self.pos]

  local swing_offset = 0
  if self.pos % 2 == 0 then
    swing_offset = self.swing
  end

  if offset_in_current_step(self) == (step.offset + swing_offset) then
    step:play(id, engine)
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
  self.default_sample_id = clamp(self.default_sample_id + delta, 1, 64)
end

function Track:delta_transpose(delta)
  self.transpose = clamp(self.transpose + delta, -24, 24)
end

function Track:default_sample_name(state)
  return state.sample_pool:name(self.default_sample_id)
end

return Track
