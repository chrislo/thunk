Pattern = {}

function Pattern.new(ppqn)
  local tracks = {}
  for i = 1, 6 do
    tracks[i] = Track.new(ppqn, i)
  end

  return {
    tracks = tracks,
    swing = 0
  }
end

function Pattern.advance(pattern)
  for k,v in ipairs(pattern.tracks) do
    pattern.tracks[k] = Track.advance(v)
  end

  return pattern
end

function Pattern.reset(pattern)
  for k,v in ipairs(pattern.tracks) do
    Track.reset(pattern.tracks[k])
  end
end

function Pattern.toggleStep(pattern, step, track)
  pattern.tracks[track] = Track.toggleStep(pattern.tracks[track], step)

  return pattern
end

function Pattern.stepsForSelectedTrack(pattern, track)
  return pattern.tracks[track].steps
end

function Pattern.setSwing(pattern, swing)
  pattern.swing = swing;

  for idx, track in ipairs(pattern.tracks) do
    pattern.tracks[idx] = Track.setSwing(track, swing)
  end

  return pattern
end

function Pattern.track(pattern, idx)
  return pattern.tracks[idx]
end

function Pattern.playSteps(pattern, engine)
  for idx, track in ipairs(pattern.tracks) do
    Track.playStep(track, engine, idx)
  end
end

function Pattern.currentlyPlayingSteps(pattern)
  local currentlyPlayingSteps = {}
  for k,v in ipairs(pattern.tracks) do
    currentlyPlayingSteps[k] = Track.currentlyPlayingStep(pattern.tracks[k])
  end
  return currentlyPlayingSteps
end

function Pattern.maybeCreatePage(pattern, track, page)
  pattern.tracks[track] = Track.maybeCreatePage(pattern.tracks[track], page)

  return pattern
end

return Pattern
