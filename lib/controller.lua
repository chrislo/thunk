Controller = {}

function Controller.handle_short_press(state, x, y)
  if y<=2 then
    local step_idx = x + ((state.selected_page[state.selected_track] - 1) * 16) + ((y-1) * 8)
    if state.shift then
      state.pattern:track(state.selected_track).length = step_idx
    else
      state.pattern:toggleStep(step_idx, state.selected_track)
    end
  end
  if y==3 and x>=5 then
    local page = x - 4

    state.selected_page[state.selected_track] = page
    state.pattern:maybeCreatePage(state.selected_track, page)
  end
  if y==8 and x>=3 then
    local track_id = x-2
    if state.shift then
      local current_mute = state.pattern:track(track_id).mute
      state.pattern:track(track_id).mute = not current_mute
    else
      state.edit_mode = 'track'
      state.selected_track = track_id
      if not state.playing then
        state.trigger_immediately = state.pattern:track(track_id).default_sample_id
      end
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

  if y <=2 and state.edit_mode == 'track' then
    state.edit_mode = 'step'
    state.selected_step = x + ((state.selected_page[state.selected_track] - 1) * 16) + ((y-1) * 8)
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

function Controller.handle_key(state, n, z)
  if n == 2 and state.edit_mode == 'track' then
    state.edit_mode = 'pattern'
    state.screen_dirty = true
  end
  if n == 2 and state.edit_mode == 'samples' then
    state.edit_mode = 'pattern'
    state.screen_dirty = true
  end
end

return Controller
