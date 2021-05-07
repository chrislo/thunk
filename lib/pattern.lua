Pattern = {}

function Pattern.new(ppqn)
  local tracks = {}
  for i = 1, 6 do
    tracks[i] = Track:new(ppqn, i)
  end

  return {
    tracks = tracks,
    swing = 0
  }
end

function Pattern.advance(pattern)
  for k,v in ipairs(pattern.tracks) do
    pattern.tracks[k]:advance()
  end

  return pattern
end

function Pattern.reset(pattern)
  for k,v in ipairs(pattern.tracks) do
    pattern.tracks[k]:reset()
  end
end

function Pattern.toggleStep(pattern, step, track)
  pattern.tracks[track]:toggleStep(step)

  return pattern
end

function Pattern.stepsForSelectedTrack(pattern, track)
  return pattern.tracks[track].steps
end

function Pattern.setSwing(pattern, swing)
  pattern.swing = swing;

  for idx, track in ipairs(pattern.tracks) do
    pattern.tracks[idx]:setSwing(swing)
  end

  return pattern
end

function Pattern.track(pattern, idx)
  return pattern.tracks[idx]
end

function Pattern.playSteps(pattern, engine)
  for idx, track in ipairs(pattern.tracks) do
    track:playStep(engine, idx)
  end
end

function Pattern.currentlyPlayingSteps(pattern)
  local currentlyPlayingSteps = {}
  for k,v in ipairs(pattern.tracks) do
    currentlyPlayingSteps[k] = pattern.tracks[k]:currentlyPlayingStep()
  end
  return currentlyPlayingSteps
end

function Pattern.maybeCreatePage(pattern, track, page)
  pattern.tracks[track]:maybeCreatePage(page)

  return pattern
end

return Pattern
