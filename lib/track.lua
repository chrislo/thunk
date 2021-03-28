M = {}

function M.new(ppqn)
  track = {
    ppqn = ppqn or 4,
    tick = 0,
    pos = 1,
    length = 16,
    steps = {Step.new(), Step.new(), Step.new(), Step.new(), Step.new(), Step.new(), Step.new(), Step.new(), Step.new(), Step.new(), Step.new(), Step.new(), Step.new(), Step.new(), Step.new(), Step.new()}
  }

  track.steps[track.pos].current = true

  return track
end

local function pulses_per_step(track)
  return (track.ppqn / 4)
end

local function advance_step(track)
  local offset_in_current_step = track.tick % pulses_per_step(track)
  return offset_in_current_step == 0
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

  if step.active then
    engine.noteOn(id, 440, 127, id-1)
  end
end

function M.currentlyPlayingStep(track)
  return track.steps[track.pos]
end

return M
