State = {}

function State:new(engine)
  state = {
    pattern = Pattern:new(PPQN),
    selected_track = 1,
    selected_page = {1, 1, 1, 1, 1, 1},
    grid_dirty = true,
    screen_dirty = true,
    shift = false,
    playing = true,
    sample_pool = SamplePool:new(engine),
    trigger_immediately = nil,
    menu = Menu:new()
  }

  state.pattern:toggleStep(1, 1)

  setmetatable(state, self)
  self.__index = self

  return state
end

function State:init()
  self.sample_pool:add_dir("/home/we/dust/audio/common/808/")
end

function State:select_track(id)
  self.selected_track = id
  self.menu:select_track()
end

function State:select_page(id)
  self.selected_page[self.selected_track] = id
  self.pattern:maybeCreatePage(self.selected_track, id)
end

function State:current_page()
  return self.selected_page[self.selected_track]
end

function State:current_track()
  return self.pattern:track(self.selected_track)
end

function State:set_track_probability(track, probability)
  track = self.pattern:track(track)
  track.probability = probability
end

function State:set_track_sample_start(track, v)
  track = self.pattern:track(track)
  track.sample_start = v
end

function State:set_track_sample_end(track, v)
  track = self.pattern:track(track)
  track.sample_end = v
end

function State:set_track_loop(track, v)
  track = self.pattern:track(track)
  track.loop = v
end

function State:current_steps()
  return state.pattern:stepsForSelectedTrack(state.selected_track)
end

function State:toggle_step(idx)
  self.pattern:toggleStep(idx, self.selected_track)
end

function State:get_selected_track()
  return self.selected_track
end

function State:current_step()
  steps = self.current_steps()
  return steps[self.selected_step]
end

return State
