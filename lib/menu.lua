Menu = {}

function Menu:new(initial)
  initial = initial or 'tempo'

  pages = {
    global = {'tempo', 'swing', 'reverb_room', 'reverb_damp', 'delay_time', 'decay_time'},
    track = {'track_sample'},
    step = {'step_sample', 'step_offset', 'step_velocity'}
  }

  events = {}

  for page, items in pairs(pages) do
    for i = 1, (#items - 1) do
      table.insert(events, { name = 'next', from = items[i], to = items[i+1] })
    end

    for i = 2, #items do
      table.insert(events, { name = 'prev', from = items[i], to = items[i-1] })
    end
  end

  table.insert(events, { name = 'select_track', from = '*', to = 'track_sample' })
  table.insert(events, { name = 'select_step',  from = '*', to = 'step_sample'  })

  for _, item in pairs(pages['track']) do
    table.insert(events, { name = 'back', from = item, to = 'tempo' })
  end

  for _, item in pairs(pages['step']) do
    table.insert(events, { name = 'back', from = item, to = 'track_sample' })
  end

  o = {
    fsm = StateMachine.create({initial = initial, events = events}),
    pages = pages
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
