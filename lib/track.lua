M = {}

function M.new()
  track = {
    pos = 1,
    length = 16,
    steps = {Step.new(), Step.new(), Step.new(), Step.new(), Step.new(), Step.new(), Step.new(), Step.new(), Step.new(), Step.new(), Step.new(), Step.new(), Step.new(), Step.new(), Step.new(), Step.new()}
  }

  track.steps[track.pos].current = true

  return track
end

function M.advance(track)
  track.steps[track.pos].current = false
  track.pos = track.pos + 1

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

function M.isActive(track, step)
  if track.steps[step].active then
    return true
  else
    return false
  end
end

function M.currentStep(track)
  return track.steps[track.pos]
end

return M
