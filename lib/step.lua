S = {}

function S.new()
  return {
    active = false,
    current = false,
    offset = 0,
    velocity = 1,
  }
end

return S
