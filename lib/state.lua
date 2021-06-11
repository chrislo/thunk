State = {}

local fsm = StateMachine.create({
  initial = 'tempo',
  events = {
    { name = 'enc_2_inc',  from = 'tempo',  to = 'swing' },
    { name = 'enc_2_inc', from = 'swing', to = 'manage_samples' },
    { name = 'enc_2_dec',  from = 'manage_samples', to = 'swing' },
    { name = 'enc_2_dec', from = 'swing', to = 'tempo' },
    { name = 'enc_3_inc', from = 'tempo', to = 'tempo' },
    { name = 'enc_3_dec', from = 'tempo', to = 'tempo' }
  },
  callbacks = {
    ontempo = function(self, event, from, to, delta)
      if event == 'enc_3_inc' or event == 'enc_3_dec' then
        params:delta("clock_tempo", delta)
      end
    end
  }
})

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
    trigger_immediately = nil,
    machine = fsm
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
