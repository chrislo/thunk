Pattern = {}

function Pattern:new(ppqn)
  local tracks = {}
  for i = 1, 6 do
    tracks[i] = Track:new(ppqn, i)
  end

  obj = {
    tracks = tracks,
    swing = 0
  }

  setmetatable(obj, self)
  self.__index = self
  return obj
end

function Pattern:advance()
  for k,v in ipairs(self.tracks) do
    self.tracks[k]:advance()
  end
end

function Pattern:reset()
  for k,v in ipairs(self.tracks) do
    self.tracks[k]:reset()
  end
end

function Pattern:toggleStep(step, track)
  self.tracks[track]:toggleStep(step)
end

function Pattern:stepsForSelectedTrack(track)
  return self.tracks[track].steps
end

function Pattern:setSwing(swing)
  self.swing = swing;

  for idx, track in ipairs(self.tracks) do
    self.tracks[idx]:setSwing(swing)
  end
end

function Pattern:track(idx)
  return self.tracks[idx]
end

function Pattern:playSteps(engine)
  for idx, track in ipairs(self.tracks) do
    track:playStep(engine, idx)
  end
end

function Pattern:currentlyPlayingSteps()
  local currentlyPlayingSteps = {}
  for k,v in ipairs(self.tracks) do
    currentlyPlayingSteps[k] = self.tracks[k]:currentlyPlayingStep()
  end
  return currentlyPlayingSteps
end

function Pattern:maybeCreatePage(track, page)
  self.tracks[track]:maybeCreatePage(page)
end

return Pattern
