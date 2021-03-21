M = {}

function M.new()
  return {
    pos = 1,
    length = 16,
    steps = {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false}
  }
end

function M.advance(track)
  track.pos = track.pos + 1

  if track.pos > track.length then
    track.pos = 1
  end

  return track
end

function M.toggleStep(track, step)
  track.steps[step] = not track.steps[step]

  return track
end

function M.isActive(track, step)
  if track.steps[step] then
    return true
  else
    return false
  end
end

function M.currentStep(track)
  return track.steps[track.pos]
end

return M
