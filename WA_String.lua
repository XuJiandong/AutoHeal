{
    ["outline"] = "OUTLINE",
    ["authorOptions"] = {
    },
    ["displayText"] = "%c",
    ["customText"] = "function()\\n    if (aura_env.text ~= nil) then\\n       return aura_env.text; \\n    end\\n    return \\\"\\\"; \\nend",
    ["yOffset"] = 43.110565185547,
    ["anchorPoint"] = "CENTER",
    ["customTextUpdate"] = "update",
    ["automaticWidth"] = "Auto",
    ["actions"] = {
        ["start"] = {
        },
        ["finish"] = {
        },
        ["init"] = {
            ["custom"] = "aura_env.lastRun = GetTime()\\naura_env.text = \\\"N/A\\\"\\n\\nlocal function smaller(value) \\n    return math.floor(value/100)\\nend\\n\\naura_env.display = function()\\n    local values = {}\\n    for i = 1, 40 do\\n        values[i] = \\\"0-0\\\"\\n    end\\n    local index = 1\\n    for unit in WA_IterateGroupMembers() do\\n        values[index] = string.format(\\\"%d-%d\\\", smaller(UnitHealth(unit)), smaller(UnitHealthMax(unit)))\\n        index = index + 1\\n    end\\n    local ret = \\\"\\\"\\n    for i = 1, 40, 5 do\\n        ret = ret .. string.format(\\\"%s-%s-%s-%s-%s\\\\n\\\", values[i], values[i+1], values[i+2],values[i+3], values[i+4])\\n    end\\n    ret = ret .. GetTime()\\n    return ret\\nend\\n\\naura_env.createDisplayText = function()\\n    local now = GetTime()\\n    if aura_env.lastRun == nil or (now - aura_env.lastRun) > 0.5 then\\n        aura_env.text = aura_env.display()\\n        aura_env.lastRun = now\\n    end\\n    return aura_env.text\\nend",
            ["do_custom"] = true,
        },
    },
    ["triggers"] = {
        [1] = {
            ["trigger"] = {
                ["type"] = "custom",
                ["spellIds"] = {
                },
                ["subeventSuffix"] = "_CAST_START",
                ["custom_hide"] = "custom",
                ["duration"] = "1",
                ["event"] = "Chat Message",
                ["unit"] = "player",
                ["custom_type"] = "status",
                ["names"] = {
                },
                ["custom"] = "-- Trigger [Every Frame]\\nfunction()\\n    aura_env.createDisplayText()\\n    return true;\\nend",
                ["events"] = "UNIT_POWER_FREQUENT",
                ["check"] = "update",
                ["unevent"] = "timed",
                ["subeventPrefix"] = "SPELL",
                ["debuffType"] = "HELPFUL",
            },
            ["untrigger"] = {
                ["custom"] = "function()\\n   return false; \\nend",
            },
        },
        ["activeTriggerMode"] = -10,
    },
    ["internalVersion"] = 29,
    ["animation"] = {
        ["start"] = {
            ["duration_type"] = "seconds",
            ["type"] = "none",
            ["easeStrength"] = 3,
            ["easeType"] = "none",
        },
        ["main"] = {
            ["duration_type"] = "seconds",
            ["type"] = "none",
            ["easeStrength"] = 3,
            ["easeType"] = "none",
        },
        ["finish"] = {
            ["duration_type"] = "seconds",
            ["type"] = "none",
            ["easeStrength"] = 3,
            ["easeType"] = "none",
        },
    },
    ["font"] = "Friz Quadrata TT",
    ["version"] = 1,
    ["subRegions"] = {
    },
    ["load"] = {
        ["spec"] = {
            ["multi"] = {
            },
        },
        ["class"] = {
            ["multi"] = {
            },
        },
        ["use_never"] = false,
        ["size"] = {
            ["multi"] = {
            },
        },
    },
    ["fontSize"] = 16,
    ["shadowXOffset"] = 1,
    ["regionType"] = "text",
    ["preferToUpdate"] = false,
    ["url"] = "https://wago.io",
    ["shadowYOffset"] = -1,
    ["justify"] = "LEFT",
    ["tocversion"] = 11303,
    ["id"] = "Raid Health",
    ["config"] = {
    },
    ["frameStrata"] = 1,
    ["anchorFrameType"] = "SCREEN",
    ["xOffset"] = -800.7132396698,
    ["uid"] = "Vj1XuIcghHM",
    ["color"] = {
        [1] = 1,
        [2] = 1,
        [3] = 1,
        [4] = 1,
    },
    ["wordWrap"] = "WordWrap",
    ["shadowColor"] = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 1,
    },
    ["fixedWidth"] = 200,
    ["conditions"] = {
    },
    ["selfPoint"] = "TOPLEFT",
}