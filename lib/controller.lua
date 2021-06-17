Controller = {}

function Controller.handle_short_press(state, x, y)
  if y<=2 then
    local step_idx = x + ((state:current_page() - 1) * 16) + ((y-1) * 8)
    if state.shift then
      state:current_track().length = step_idx
    else
      state:toggle_step(step_idx)
    end
  end
  if y==3 and x>=5 then
    local page = x - 4
    state:select_page(page)
  end
  if y==8 and x>=3 then
    local track_id = x-2
    if state.shift then
      local current_mute = state.pattern:track(track_id).mute
      state.pattern:track(track_id).mute = not current_mute
    else
      state:select_track(track_id)
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

  if y <=2 then
    state.menu:select_step()
    state.selected_step = x + ((state:current_page() - 1) * 16) + ((y-1) * 8)
  end

  state.grid_dirty = true
  state.screen_dirty = true
end

function Controller.handle_long_release(state, x, y)
  if y<=2 then
    state.grid_dirty = true
    state.screen_dirty = true
    state.menu:back()
  end

  if y==8 and x==1 then
    state.shift = false
    state.grid_dirty = true
  end
end

function Controller.handle_key(state, n, z)
  if n == 2 then
    state.menu:back()
    state.screen_dirty = true
  end
end

function Controller.handle_enc(state, n, delta)
  if n == 2 then
    if delta > 0 then
      state.menu:next()
    elseif delta < 0 then
      state.menu:prev()
    end
  end

  if n == 3 then
    if     state.menu:is("tempo") then params:delta("clock_tempo", delta)
    elseif state.menu:is("swing") then params:delta("swing", delta)
    elseif state.menu:is("track_sample") then print("track_sample")
    elseif state.menu:is("step_sample") then print("step_sample")
    elseif state.menu:is("step_offset") then print("step_offset")
    elseif state.menu:is("step_velocity") then print("step_velocity")
    end
  end

  state.screen_dirty = true
end

return Controller
