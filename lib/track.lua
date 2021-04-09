M = {}

function M.new(ppqn)
  local steps = {}
  for i = 1, 64 do
    steps[i] = Step.new()
  end

  track = {
    ppqn = ppqn or 4,
    tick = 0,
    pos = 1,
    length = 16,
    steps = steps
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

function M.offsetEvenSteps(track, offset)
  for i, step in ipairs(track.steps) do
    if (i % 2 == 0) then
      track.steps[i].offset = offset
    end
  end

  return track
end

function M.playStep(track, engine, id)
  local step = track.steps[track.pos]

  if step.active and (offset_in_current_step(track) == step.offset) then
    engine.noteOn(id, 440, 127, id)
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
