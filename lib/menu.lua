Menu = {}

function Menu:new(initial)
  initial = initial or 'tempo'

  events = {
    { name = 'next',         from = 'tempo',          to = 'swing'             },
    { name = 'next',         from = 'swing',          to = 'manage_samples'    },
    { name = 'prev',         from = 'manage_samples', to = 'swing'             },
    { name = 'prev',         from = 'swing',          to = 'tempo'             },
    { name = 'next',         from = 'track_sample',   to = 'track_sample'      },
    { name = 'prev',         from = 'track_sample',   to = 'track_sample'      },
    { name = 'next',         from = 'step_sample',    to = 'step_offset'       },
    { name = 'next',         from = 'step_offset',    to = 'step_velocity'     },
    { name = 'prev',         from = 'step_velocity',  to = 'step_offset'       },
    { name = 'prev',         from = 'step_offset',    to = 'step_sample'       },
    { name = 'select_track', from = '*',              to = 'track_sample'      },
  }

  o = {
    fsm = StateMachine.create({initial = initial, events = events})
  }

  setmetatable(o, self)
  self.__index = self

  return o
end

function Menu:page()
  pages = {
    global = {'tempo', 'swing', 'manage_samples'},
    track = {'track_sample'},
    step = {'step_sample', 'step_offset', 'step_velocity'}
  }

  for page, items in pairs(pages) do
    for k, item in pairs(items) do
      if self.fsm:is(item) then
        return page
      end
    end
  end
end

function Menu:select_track()
  self.fsm:select_track()
end

return Menu
