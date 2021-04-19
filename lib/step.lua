S = {}

function S.new()
  return {
    active = false,
    current = false,
    offset = 0,
    velocity = 1,
  }
end

function S.delta_offset(step, delta)
  step.offset = step.offset + delta
end

function S.delta_velocity(step, delta)
  step.velocity = step.velocity + (delta * 0.1)
end

return S
