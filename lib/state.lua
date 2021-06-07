State = {}

function State:new()
  state = {
    pattern = Pattern:new(PPQN),
    selected_track = 1,
    selected_page = {1, 1, 1, 1, 1, 1},
    grid_dirty = true,
    screen_dirty = true,
    shift = false,
    playing = true,
    edit_mode = 'track',
    sample_pool = SamplePool:new(),
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

return State
