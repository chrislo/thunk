C = {}

function C.handle_press(state, x, y)
  if y==1 then
    local step_to_toggle = x + ((state.selected_page[state.selected_track] - 1) * 16)
    state.pattern = Pattern.toggleStep(state.pattern, step_to_toggle, state.selected_track)
  end
  if y==2 then
    local step_to_toggle = x + ((state.selected_page[state.selected_track] - 1) * 16) + 8
    state.pattern = Pattern.toggleStep(state.pattern, step_to_toggle, state.selected_track)
  end
  if y==3 and x>=5 then
    local page = x - 4
    state.selected_page[state.selected_track] = page
    state.pattern = Pattern.maybeCreatePage(state.pattern, state.selected_track, page)
  end
  if y==8 and x>=3 then
    state.selected_track = x-2
  end

  return state
end

function C.handle_long_press(state, x, y)
  if y==1 then
    state.selected_step = x + ((state.selected_page[state.selected_track] - 1) * 16)
  end
  if y==2 then
    state.selected_step = x + ((state.selected_page[state.selected_track] - 1) * 16) + 8
  end

  return state
end

return C