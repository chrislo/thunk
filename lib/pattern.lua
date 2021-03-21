M = {}

function M.new()
  return {
    pos = 1,
    length = 16,
    steps = {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false}
  }
end

function M.advance(pattern)
  pattern.pos = pattern.pos + 1

  if pattern.pos > pattern.length then
    pattern.pos = 1
  end

  return pattern
end

function M.toggleStep(pattern, step)
  pattern.steps[step] = not pattern.steps[step]

  return pattern
end

function M.isActive(pattern, step)
  if pattern.steps[step] then
    return true
  else
    return false
  end
end

return M
