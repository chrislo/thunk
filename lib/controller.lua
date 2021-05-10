Controller = {}

function Controller.handle_short_press(state, x, y)
  if y<=2 then
    if state.edit_mode == 'sample' then
      sample_id = x + ((state.selected_bank - 1) * 16) + ((y-1) * 8)

      if state.shift then
        state.pattern:track(state.selected_track).default_sample_id = sample_id
      else
        state.selected_sample = sample_id
        state.trigger_immediately = sample_id
      end
    else
      local step_idx = x + ((state.selected_page[state.selected_track] - 1) * 16) + ((y-1) * 8)
      if state.shift then
        state.pattern:track(state.selected_track).length = step_idx
      else
        state.pattern:toggleStep(step_idx, state.selected_track)
      end
    end
  end
  if y==3 and x>=5 then
    local page = x - 4

    if state.edit_mode == 'sample' then
      state.selected_bank = page
    else
      state.selected_page[state.selected_track] = page
      state.pattern:maybeCreatePage(state.selected_track, page)
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
    local track_id = x-2
    if state.shift then
      local current_mute = state.pattern:track(track_id).mute
      state.pattern:track(track_id).mute = not current_mute
    else
      state.selected_track = track_id
      state.selected_sample = state.pattern:track(track_id).default_sample_id
    end
  end
  if y==7 and x==1 then
    state.playing = not state.playing

    if (not state.playing) then
      state.pattern:reset()
    end
  end

  state.grid_dirty = true
  state.screen_dirty = true
end

function Controller.handle_long_press(state, x, y)
  if y==8 and x==1 then
    state.shift = true
    return
  end

  if state.edit_mode == 'track' then
    state.edit_mode = 'step'

    if y==1 then
      state.selected_step = x + ((state.selected_page[state.selected_track] - 1) * 16)
    end
    if y==2 then
      state.selected_step = x + ((state.selected_page[state.selected_track] - 1) * 16) + 8
    end
  end

  state.grid_dirty = true
  state.screen_dirty = true
end

function Controller.handle_long_release(state, x, y)
  if y<=2 then
    state.grid_dirty = true
    state.screen_dirty = true

    if state.edit_mode == 'step' then
      state.edit_mode = 'track'
    end
  end

  if y==8 and x==1 then
    state.shift = false
    state.grid_dirty = true
  end
end

return Controller
