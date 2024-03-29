Menu = {}

function Menu:new(initial)
  initial = initial or 'tempo'

  pages = {
    global = {'tempo', 'swing', 'reverb_room', 'reverb_damp', 'delay_time', 'decay_time'},
    track = {'track_sample', 'track_transpose', 'volume', 'cutoff', 'resonance', 'loop', 'sample_start', 'sample_end', 'duration', 'attack', 'release', 'filter', 'filter_attack', 'filter_release', 'filter_cutoff', 'filter_rq', 'reverb_send', 'delay_send', 'probability'},
    step = {'step_sample', 'step_transpose', 'step_offset', 'step_velocity', 'step_duration'}
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

local function format_boolean(key, value)
  local v
  if value == 1 then
    v = 'on'
  else
    v = 'off'
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
  elseif item == 'delay_time' then
    return format_menu_item(item, Delay.options()[params:get("delay_time")])
  elseif item == 'swing' then
    return format_menu_item(item, swing_as_percentage(params:get("swing")))
  elseif item == 'track_sample' then
    return format_menu_item('Sample', state:current_track():default_sample_name(state))
  elseif item == 'track_transpose' then
    return format_menu_item('Transpose', state:current_track().transpose)
  elseif item == 'volume' then
    return format_menu_item('Volume', params:get("t" .. state:get_selected_track() .. "_volume"))
  elseif item == 'cutoff' then
    return format_menu_item('Cutoff', params:get("t" .. state:get_selected_track() .. "_cutoff"))
  elseif item == 'resonance' then
    return format_menu_item('Resonance', params:get("t" .. state:get_selected_track() .. "_resonance"))
  elseif item == 'loop' then
    return format_boolean('Loop', params:get("t" .. state:get_selected_track() .. "_loop"))
  elseif item == 'sample_start' then
    return format_menu_item('Start', params:get("t" .. state:get_selected_track() .. "_sample_start"))
  elseif item == 'sample_end' then
    return format_menu_item('End', params:get("t" .. state:get_selected_track() .. "_sample_end"))
  elseif item == 'duration' then
    return format_menu_item('Duration', params:get("t" .. state:get_selected_track() .. "_duration"))
  elseif item == 'attack' then
    return format_menu_item('Attack', params:get("t" .. state:get_selected_track() .. "_attack"))
  elseif item == 'release' then
    return format_menu_item('Release', params:get("t" .. state:get_selected_track() .. "_release"))
  elseif item == 'filter' then
    return format_boolean('Filter', params:get("t" .. state:get_selected_track() .. "_filter"))
  elseif item == 'filter_attack' then
    return format_menu_item('Filter attack', params:get("t" .. state:get_selected_track() .. "_filter_attack"))
  elseif item == 'filter_release' then
    return format_menu_item('Filter release', params:get("t" .. state:get_selected_track() .. "_filter_release"))
  elseif item == 'filter_cutoff' then
    return format_menu_item('Filter cutoff', params:get("t" .. state:get_selected_track() .. "_filter_cutoff"))
  elseif item == 'filter_rq' then
    return format_menu_item('Filter RQ', params:get("t" .. state:get_selected_track() .. "_filter_rq"))
  elseif item == 'delay_send' then
    return format_menu_item('Delay Send', params:get("t" .. state:get_selected_track() .. "_delay_send"))
  elseif item == 'reverb_send' then
    return format_menu_item('Reverb Send', params:get("t" .. state:get_selected_track() .. "_reverb_send"))
  elseif item == 'probability' then
    return format_menu_item('Probability', params:get("t" .. state:get_selected_track() .. "_probability"))
  elseif item == 'step_sample' then
    return format_menu_item('Sample', state:current_step():sample_name(state))
  elseif item == 'step_transpose' then
    return format_menu_item('Transpose', state:current_step():transpose_or_default())
  elseif item == 'step_offset' then
    return format_menu_item('Offset', state:current_step().offset)
  elseif item == 'step_velocity' then
    return format_menu_item('Velocity', state:current_step().velocity)
  elseif item == 'step_duration' then
    return format_menu_item('Duration', state:current_step():duration_or_default())
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
