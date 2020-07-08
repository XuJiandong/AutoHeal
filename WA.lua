aura_env.lastRun = nil
aura_env.text = "N/A"
aura_env.fre = 0.1 -- update frequency
aura_env.threshold = 100 -- unit: 100, return 000000 if damaged heal is less than this threshold

local function getUnit(index)
    local unit  = IsInRaid() and 'raid' or 'party'
    return string.format("%s%d", unit, index)
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
        local offline = Grid2:GetStatusByName("offline")
        if offline and offline:IsActive(unit) then
            return 0
        end        
    end
    return  max_health - health
end


aura_env.display = function()
    local values = {}
    for i = 1, 40 do
        values[i] = {0, 0}
    end
    local subgroup_count = {}
    local debug = {}
    for i = 1, GetNumGroupMembers() do
        local name, _, subgroup, _, _ = GetRaidRosterInfo(i)
        if not subgroup_count[subgroup] then
            subgroup_count[subgroup] = 1
        else
            subgroup_count[subgroup] = subgroup_count[subgroup] + 1
        end

        index = (subgroup - 1)*5 + subgroup_count[subgroup]

        local unit = getUnit(index)
        values[index] = {index, deficit(unit)}
        table.insert(debug, string.format("%d, %q", index, name))
    end


    table.sort(values, function(a, b) return a[2] > b[2] end)
    if values[1][2] < aura_env.threshold then
        ret = "000000"
    else
        ret = string.format("%02d%02d%02d", values[1][1], values[2][1], values[3][1])
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
