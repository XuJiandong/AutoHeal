require "os"
require "math"

aura_env = {}

function GetTime()
    return os.time()
end

function IsInRaid()
    return true
end

function GetNumSubgroupMembers()
    return 5
end

function GetNumGroupMembers()
    return 40
end

function WA_IterateGroupMembers (reversed, forceParty)
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

math.randomseed(os.time())
local index = math.random(1, 40)
function UnitHealth(unit)
    if unit == string.format("raid%d", index) then
        return 100
    else
        return 1000
    end
end

function UnitHealthMax(unit)
    return 1000
end

require "WA"

local result = aura_env.createDisplayText()
local new_index = tonumber(result:sub(1, 2))
print(string.format("%d vs %d", index, new_index))
if new_index == index then
    print("passed")
else
    print("not passed")
end
