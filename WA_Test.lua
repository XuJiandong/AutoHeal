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

function UnitClass(unit)
    return "", 3
end

function GetSpellInfo(s)
    return 0
end

function IsSpellInRange(a, b)
    return 1
end

function UnitIsDeadOrGhost(unit)
    return false
end

function UnitExists(unit)
    return true
end

function  GetRaidRosterInfo(i) 
    return "", "", math.floor((i-1)/5)+1, ""
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
INDEX = math.random(1, 40)
function UnitHealth(unit)
    if unit == string.format("raid%d", INDEX) then
        return 100
    else
        return 1000
    end
end

function UnitHealth2(unit)
    if unit == string.format("raid%d", INDEX) then
        return 1000
    else
        return 1000
    end
end

function UnitHealthMax(unit)
    return 1000
end

require "WA"

local passed = true
aura_env.fre = -1
for i = 1, 10 do
    INDEX = math.random(1, 40)
    local result = aura_env.createDisplayText()
    local new_index = tonumber(result:sub(1, 2))
    if new_index ~= INDEX then
        print("not passed")
        print(string.format("%d vs %d", INDEX, new_index))
        passed = false
        break
    end
end

-- test "000000"
UnitHealth = UnitHealth2

for i = 1, 10 do
    INDEX = math.random(1, 40)
    local result = aura_env.createDisplayText()
    local new_index = tonumber(result:sub(1, 2))
    if new_index ~= 0 then
        print("not passed")
        print(string.format("%d vs %d", INDEX, new_index))
        passed = false
        break
    end
end

-- test out of range, death, not exist
for i = 1, 10 do

    function IsSpellInRange(a, b)
        return 1
    end

    function UnitIsDeadOrGhost(unit)
        return false
    end

    function UnitExists(unit)
        return true
    end
    local choice = math.random(1, 3)
    if choice == 1 then
        IsSpellInRange = function(s, u)
            return 0
        end
    elseif choice == 2 then
        UnitIsDeadOrGhost = function (unit)
            return true
        end
    else
        UnitExists = function (unit)
            return false
        end
    end

    INDEX = math.random(1, 40)
    local result = aura_env.createDisplayText()
    if result ~= "000000" then
        print("out of range, not passed")
        passed = false
        break
    end
end


if passed then
    print("passed")
else
    print("not passed")
end
