P = {}

function P.new()
  return {
    selectedTrack = 1,
    tracks = { Track.new(), Track.new(), Track.new(), Track.new(), Track.new(), Track.new() }
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

function P.stepsForSelectedTrack(pattern)
  return pattern.tracks[pattern.selectedTrack].steps
end

function P.currentlyPlayingSteps(pattern)
  local currentlyPlayingSteps = {}
  for k,v in ipairs(pattern.tracks) do
    currentlyPlayingSteps[k] = Track.currentlyPlayingStep(pattern.tracks[k])
  end
  return currentlyPlayingSteps
end

return P
