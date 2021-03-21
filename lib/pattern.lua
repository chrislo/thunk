P = {}

function P.new()
  return {
    selectedTrack = 1,
    tracks = { Track.new(), Track.new() }
  }
end

function P.advance(pattern)
  for k,v in ipairs(pattern.tracks) do
    pattern.tracks[k] = Track.advance(v)
  end

  return pattern
end

function P.toggleStep(pattern, step)
  pattern.tracks[pattern.selectedTrack] = Track.toggleStep(pattern.tracks[pattern.selectedTrack], step)

  return pattern
end

function P.positionOfSelectedTrack(pattern)
  return pattern.tracks[pattern.selectedTrack].pos
end

function P.selectedTrackIsActive(pattern, step)
  return Track.isActive(pattern.tracks[pattern.selectedTrack], step)
end

function P.currentSteps(pattern)
  local currentSteps = {}
  for k,v in ipairs(pattern.tracks) do
    currentSteps[k] = Track.currentStep(pattern.tracks[k])
  end
  return currentSteps
end

return P
