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
    { name = 'select_step',  from = '*',              to = 'step_sample'       },
    { name = 'back',         from = 'track_sample',   to = 'tempo'             },
    { name = 'back',         from = 'step_sample',    to = 'track_sample'      },
    { name = 'back',         from = 'step_offset',    to = 'track_sample'      },
    { name = 'back',         from = 'step_velocity',  to = 'track_sample'      },
  }

  o = {
    fsm = StateMachine.create({initial = initial, events = events}),
    pages = {
      global = {'tempo', 'swing', 'manage_samples'},
      track = {'track_sample'},
      step = {'step_sample', 'step_offset', 'step_velocity'}
    }
  }

  setmetatable(o, self)
  self.__index = self

  return o
end

function Menu:page()
  for page, items in pairs(self.pages) do
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

function Menu:next()
  self.fsm:next()
end

function Menu:prev()
  self.fsm:prev()
end

function Menu:back()
  self.fsm:back()
end

function Menu:select_track()
  self.fsm:select_track()
end

function Menu:select_step()
  self.fsm:select_step()
end

function Menu:is(x)
  return self.fsm:is(x)
end

function Menu:draw()
  items = self.pages[self:page()]
  for idx, item in pairs(items) do
    if self:is(item) then
      current_idx = idx
    end
  end

  list = UI.ScrollingList.new(0, 0, current_idx, items)
  list:redraw()
end

return Menu
