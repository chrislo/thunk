Controller = {}

function Controller.handle_short_press(state, x, y)
  if y<=2 then
    if state.edit_mode == 'sample' then
      state.selected_sample  = x + ((state.selected_bank - 1) * 16) + ((y-1) * 8)
    else
      local step_idx = x + ((state.selected_page[state.selected_track] - 1) * 16) + ((y-1) * 8)
      if state.shift then
        Pattern.track(state.pattern, state.selected_track).length = step_idx
      else
        state.pattern = Pattern.toggleStep(state.pattern, step_idx, state.selected_track)
      end
    end
  end
  if y==3 and x>=5 then
    local page = x - 4

    if state.edit_mode == 'sample' then
      state.selected_bank = page
    else
      state.selected_page[state.selected_track] = page
      state.pattern = Pattern.maybeCreatePage(state.pattern, state.selected_track, page)
    end
  end
  if y==3 and x<=2 then
    if x == 1 then
      state.edit_mode = 'track'
    elseif x == 2 then
      state.edit_mode = 'sample'
    end
  end
  if y==8 and x>=3 then
    state.selected_track = x-2
  end
  if y==7 and x==1 then
    state.playing = not state.playing

    if (not state.playing) then
      Pattern.reset(state.pattern)
    end
  end

  state.grid_dirty = true
end

function Controller.handle_long_press(state, x, y)
  if y==1 then
    state.selected_step = x + ((state.selected_page[state.selected_track] - 1) * 16)
  end
  if y==2 then
    state.selected_step = x + ((state.selected_page[state.selected_track] - 1) * 16) + 8
  end
  if y==8 and x==1 then
    state.shift = true
  end

  state.grid_dirty = true
  state.screen_dirty = true
end

function Controller.handle_long_release(state, x, y)
  if y<=2 then
    state.selected_step = nil
    state.grid_dirty = true
    state.screen_dirty = true
  end

  if y==8 and x==1 then
    state.shift = false
    state.grid_dirty = true
  end
end

return Controller
