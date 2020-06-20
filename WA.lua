aura_env.lastRun = GetTime()
aura_env.text = "N/A"

local function smaller(value) 
  return math.floor(value/100)
end

aura_env.display = function()
  local values = {}
  for i = 1, 40 do
      values[i] = "0-0"
  end
  local index = 1
  for unit in WA_IterateGroupMembers() do
      values[index] = string.format("%d-%d", smaller(UnitHealth(unit)), smaller(UnitHealthMax(unit)))
      index = index + 1
  end
  local ret = ""
  for i = 1, 40, 5 do
      ret = ret .. string.format("%s-%s-%s-%s-%s\n", values[i], values[i+1], values[i+2],values[i+3], values[i+4])
  end
  ret = ret .. GetTime()
  return ret
end

aura_env.createDisplayText = function()
  local now = GetTime()
  if aura_env.lastRun == nil or (now - aura_env.lastRun) > 0.5 then
    aura_env.text = aura_env.display()
    aura_env.lastRun = now
  end
  return aura_env.text
end
