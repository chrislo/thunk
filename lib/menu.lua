Menu = {}

function Menu:new(initial)
  initial = initial or 'tempo'

  events = {
    { name = 'next',         from = 'tempo',          to = 'swing'             },
    { name = 'prev',         from = 'swing',          to = 'tempo'             },
    { name = 'next',         from = 'swing',          to = 'reverb_room'       },
    { name = 'prev',         from = 'reverb_room',    to = 'swing'             },
    { name = 'next',         from = 'reverb_room',    to = 'reverb_damp'       },
    { name = 'prev',         from = 'reverb_damp',    to = 'reverb_room'       },
    { name = 'next',         from = 'reverb_damp',    to = 'delay_time'        },
    { name = 'prev',         from = 'delay_time',     to = 'reverb_damp'       },
    { name = 'next',         from = 'delay_time',     to = 'decay_time'        },
    { name = 'prev',         from = 'decay_time',     to = 'delay_time'        },
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
      global = {'tempo', 'swing', 'reverb_room', 'reverb_damp', 'delay_time', 'decay_time'},
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

local function format_menu_item(key, value)
  local v
  if type(value) == 'number' then
    v = string.format("%.2f", value)
  else
    v = tostring(value)
  end
  local max_width = 30
  local spaces_to_insert = max_width - string.len(key) - string.len(v) - 1

  return key .. string.rep(" ", spaces_to_insert) .. v
end

local function swing_as_percentage(pulses)
  return math.floor(50 + pulses * (50 / (PPQN/4))) .. "%"
end

local function format_item(item,state)
  if item == 'tempo' then
    return format_menu_item(item, params:get("clock_tempo"))
  elseif item == 'swing' then
    return format_menu_item(item, swing_as_percentage(params:get("swing")))
  elseif item == 'track_sample' then
    return format_menu_item('Sample', state:current_track():default_sample_name(state))
  elseif item == 'step_sample' then
    return format_menu_item('Sample', state:current_step():sample_name(state))
  elseif item == 'step_offset' then
    return format_menu_item('Offset', state:current_step().offset)
  elseif item == 'step_velocity' then
    return format_menu_item('Velocity', state:current_step().velocity)
  elseif params:get(item) then
    return format_menu_item(item, params:get(item))
  else
    return item
  end
end

function Menu:draw(state)
  items = self.pages[self:page()]
  display_items = {}

  for idx, item in pairs(items) do
    if self:is(item) then
      current_idx = idx
    end
    display_items[idx] = format_item(item, state)
  end

  list = UI.ScrollingList.new(0, 0, current_idx, display_items)
  list:redraw()
end

return Menu
