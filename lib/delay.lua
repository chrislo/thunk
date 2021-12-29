Delay = {}

local mappings = {
  ['1/128'] = 1,
  ['1/64'] = 2,
  ['1/64.'] = 3,
  ['1/32'] = 4,
  ['1/32.'] = 6,
  ['1/16'] = 8,
  ['1/16.'] = 12,
  ['1/8'] = 16,
  ['1/8.'] = 24,
  ['1/4'] = 32,
  ['1/4.'] = 48,
  ['1/2'] = 64,
  ['1/2.'] = 96,
  ['1'] = 128
}

function Delay.options()
  local sorted_options = {}

  for ratio, time in pairs(mappings) do
    table.insert(sorted_options, {ratio, time})
  end

  table.sort(sorted_options, function(a,b) return a[2] < b[2] end)

  local options = {}

  for k,v in pairs(sorted_options) do
    table.insert(options, v[1])
  end

  return options
end

function Delay.ratio_to_ms(ratio, tempo)
  i = (60000 / tempo) / 32;

  return mappings[ratio] * i
end

function Delay.ratio_to_seconds(ratio, tempo)
  print(ratio)
  print(tempo)
  return Delay.ratio_to_ms(ratio, tempo) / 1000
end

return Delay
