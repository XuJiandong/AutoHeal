aura_env.lastRun = nil
aura_env.text = "N/A"
aura_env.fre = 0.1 -- update frequency
aura_env.threshold = 5 -- unit: 100, return 000000 if damaged heal is less than this threshold

local function smaller(value)
    return math.floor(value/100)
end

aura_env.display = function()
    local values = {}
    for i = 1, 40 do
        values[i] = {0, 0, 0}
    end
    local index = 1
    for unit in WA_IterateGroupMembers() do
        values[index] = {index, smaller(UnitHealth(unit)), smaller(UnitHealthMax(unit))}
        index = index + 1
    end
    table.sort(values, function(a,b) return (a[3] - a[2]) > (b[3] - b[2]) end)
    if (values[1][3] - values[1][2]) < aura_env.threshold then
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
