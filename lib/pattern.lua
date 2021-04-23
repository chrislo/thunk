P = {}

function P.new(ppqn)
  local tracks = {}
  for i = 1, 6 do
    tracks[i] = Track.new(ppqn, i)
  end

  return {
    tracks = tracks,
    swing = 0
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

function P.setSwing(pattern, swing)
  pattern.swing = swing;

  for idx, track in ipairs(pattern.tracks) do
    pattern.tracks[idx] = Track.setSwing(track, swing)
  end

  return pattern
end

function P.track(pattern, idx)
  return pattern.tracks[idx]
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

function P.maybeCreatePage(pattern, track, page)
  pattern.tracks[track] = Track.maybeCreatePage(pattern.tracks[track], page)

  return pattern
end

return P
