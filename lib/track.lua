M = {}

function M.new(ppqn, default_sample_id)
  local steps = {}
  for i = 1, 64 do
    steps[i] = Step.new(default_sample_id)
  end

  track = {
    ppqn = ppqn or 4,
    tick = 0,
    pos = 1,
    length = 16,
    steps = steps,
    swing = 0
  }

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

function M.advance(track)
  track.steps[track.pos].current = false
  track.tick = track.tick + 1

  if advance_step(track) then
    track.pos = track.pos + 1
  end

  if track.pos > track.length then
    track.pos = 1
  end

  track.steps[track.pos].current = true

  return track
end

function M.toggleStep(track, step)
  track.steps[step].active = not track.steps[step].active

  return track
end

function M.setSwing(track, swing)
  track.swing = swing

  return track
end

function M.playStep(track, engine, id)
  local step = track.steps[track.pos]

  local swing_offset = 0
  if track.pos % 2 == 0 then
    swing_offset = track.swing
  end

  if step.active and (offset_in_current_step(track) == (step.offset + swing_offset)) then
    engine.noteOn(id, 440, step.velocity / 127, step.sample_id)
  end
end

function M.currentlyPlayingStep(track)
  return track.steps[track.pos]
end

function M.maybeCreatePage(track, page)
  local number_of_pages = math.ceil(track.length / 16)

  if page > number_of_pages then
    track.length = 16 * page
  end

  return track
end

return M
