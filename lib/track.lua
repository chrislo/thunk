Track = {}

function Track.new(ppqn, default_sample_id)
  local steps = {}
  for i = 1, 64 do
    steps[i] = Step.new()
  end

  track = {
    ppqn = ppqn or 4,
    tick = 0,
    pos = 1,
    length = 16,
    steps = steps,
    swing = 0,
    default_sample_id = default_sample_id
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

function Track.advance(track)
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

function Track.reset(track)
  track.pos = 1
end

function Track.toggleStep(track, step)
  track.steps[step].active = not track.steps[step].active

  return track
end

function Track.setSwing(track, swing)
  track.swing = swing

  return track
end

function Track.playStep(track, engine, id)
  local step = track.steps[track.pos]

  local swing_offset = 0
  if track.pos % 2 == 0 then
    swing_offset = track.swing
  end

  local sample_id = nil
  if step.sample_id then
    sample_id = step.sample_id
  else
    sample_id = track.default_sample_id
  end

  if step.active and (offset_in_current_step(track) == (step.offset + swing_offset)) then
    engine.noteOn(id, 440, step.velocity / 127, sample_id)
  end
end

function Track.currentlyPlayingStep(track)
  return track.steps[track.pos]
end

function Track.maybeCreatePage(track, page)
  local number_of_pages = math.ceil(track.length / 16)

  if page > number_of_pages then
    track.length = 16 * page
  end

  return track
end

return Track
