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
    edit_mode = 'track',
    sample_pool = SamplePool:new(engine),
    trigger_immediately = nil
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
end

function State:select_page(id)
  self.selected_page[self.selected_track] = id
  self.pattern:maybeCreatePage(self.selected_track, id)
end

return State
