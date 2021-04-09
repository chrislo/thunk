P = {}

function P.new(ppqn)
  return {
    tracks = { Track.new(ppqn), Track.new(ppqn), Track.new(ppqn), Track.new(ppqn), Track.new(ppqn), Track.new(ppqn) }
  }
end

function P.advance(pattern)
  for k,v in ipairs(pattern.tracks) do
    pattern.tracks[k] = Track.advance(v)
  end

  return pattern
end

function P.toggleStep(pattern, step, track)
  pattern.tracks[track] = Track.toggleStep(pattern.tracks[track], step)

  return pattern
end

function P.stepsForSelectedTrack(pattern, track)
  return pattern.tracks[track].steps
end

function P.offsetAllEvenSteps(pattern, offset)
  for idx, track in ipairs(pattern.tracks) do
    pattern.tracks[idx] = Track.offsetEvenSteps(track, offset)
  end

  return pattern
end

function P.playSteps(pattern, engine)
  for idx, track in ipairs(pattern.tracks) do
    Track.playStep(track, engine, idx)
  end
end

function P.currentlyPlayingSteps(pattern)
  local currentlyPlayingSteps = {}
  for k,v in ipairs(pattern.tracks) do
    currentlyPlayingSteps[k] = Track.currentlyPlayingStep(pattern.tracks[k])
  end
  return currentlyPlayingSteps
end

return P
