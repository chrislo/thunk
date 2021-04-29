Step = {}

function Step.new()
  return {
    active = false,
    current = false,
    offset = 0,
    velocity = 127,
    sample_id = nil
  }
end

local function clamp(n, min, max)
  return math.min(max,(math.max(n,min)))
end

function Step.delta_offset(step, delta)
  step.offset = clamp(step.offset + delta, 0, PPQN/4)
end

function Step.delta_velocity(step, delta)
  step.velocity = clamp(step.velocity + delta, 0, 127)
end

function Step.delta_sample_id(step, default, delta)
  local sample_id
  if step.sample_id then
    sample_id = step.sample_id
  else
    sample_id = default
  end

  step.sample_id = clamp(sample_id + delta, 1, 128)
end

return Step
