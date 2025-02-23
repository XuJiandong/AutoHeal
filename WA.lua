aura_env.lastRun = nil
aura_env.text = "N/A"
aura_env.fre = 0.1 -- update frequency
aura_env.threshold = 700 -- unit: 100, return 000000 if damaged heal is less than this threshold

local function getUnit(index)
    local unit  = IsInRaid() and 'raid' or 'party'
    return string.format("%s%d", unit, index)
end

local offline = nil
local grid_deficit = nil

local function my_tonumber(text)
    local found = string.find(text, "k")
    text = string.gsub(text, "k", "")
    local ret = tonumber(text)
    if found then
        ret = ret * 1000
    end
    return math.abs(ret)
end

local function deficit(unit) 
    if UnitIsDeadOrGhost(unit) or not UnitExists(unit) then
        return 0
    end
    local max_health = UnitHealthMax(unit)
    local health = UnitHealth(unit)
    if max_health == 0 or health == 0 then
        return 0
    end
    if UnitIsFeignDeath and  UnitIsFeignDeath(unit) then
        return 0
    end
    if UnitInRange and not UnitInRange(unit) then
        return 0
    end
    if Grid2 and Grid2.GetStatusByName then
        if not offline then
            offline = Grid2:GetStatusByName("offline")
        end
        if offline and offline:IsActive(unit) then
            return 0
        end
        -- use Grid's deficit
        if not grid_deficit then
            grid_deficit = Grid2:GetStatusByName("health-deficit")
        end
        if grid_deficit and grid_deficit:IsActive(unit) then
            local d = grid_deficit:GetText(unit)
            if d then
                local v = my_tonumber(d)
                if v > 0 then
                    return v
                end
            end
        end
    end
    return  math.abs(max_health - health)
end


aura_env.display = function()
    local values = {}
    local member_count = GetNumGroupMembers()
    if not IsInRaid() or member_count < 1 then
        return "00"
    end

    for i = 1, member_count do
        values[i] = {0, 0, nil}
    end
    local subgroup_count = {}
    for i = 1, member_count do
        local unit = getUnit(i)
        if UnitIsPlayer(unit) then
            local name, _, subgroup, _, _ = GetRaidRosterInfo(i)
            if not subgroup_count[subgroup] then
                subgroup_count[subgroup] = 1
            else
                subgroup_count[subgroup] = subgroup_count[subgroup] + 1
            end
            
            local col_row = string.format("%d%d", subgroup, subgroup_count[subgroup])            
            values[i] = {col_row, deficit(unit), name}
        else
            values[i] = {"00", 0, "Not Player"}
        end
    end
    
    table.sort(values, function(a, b) return a[2] > b[2] end)
    if values[1][2] < aura_env.threshold then
        ret = "00"
    else
        ret = string.format("%s%d%s", values[1][1], values[1][2], tostring(values[1][3]))
    end
    return ret
end

aura_env.createDisplayText = function()
    local now = GetTime()
    if aura_env.lastRun == nil or (now - aura_env.lastRun) > aura_env.fre then
        aura_env.text = aura_env.display()
        aura_env.lastRun = now
    end
    return aura_env.text
end

