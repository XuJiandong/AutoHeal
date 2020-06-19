
--[[
local WA_IterateGroupMembers = function(reversed, forceParty)
  local unit  = (not forceParty and IsInRaid()) and 'raid' or 'party'
  local numGroupMembers = (forceParty and GetNumSubgroupMembers()  or GetNumGroupMembers())
  local i = reversed and numGroupMembers or (unit == 'party' and 0 or 1)
  return function()
    local ret
    if i == 0 and unit == 'party' then
      ret = 'player'
    elseif i <= numGroupMembers and i > 0 then
      ret = unit .. i
    end
    i = i + (reversed and -1 or 1)
    return ret
  end
end
]]
aura_env.createDisplayText = function()
    values = {}
    for i = 1, 40 do
        values[i] = "0-0"
    end
    index = 1
    for i in WA_IterateGroupMembers() do
        values[index] = string.format("%d-%d", UnitHealth(unit), UnitHealthMax(unit))
        index = index + 1
    end
    ret = ""
    for i = 1, 40, 5 do
        ret = ret .. string.format("%s-%s-%s-%s-%s\n", values[i], values[i+1], values[i+2],values[i+3], values[i+4])
    end
    return ret
end
