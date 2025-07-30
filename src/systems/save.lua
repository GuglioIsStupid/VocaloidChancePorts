local Save = {}

function Save.migrateSave(save)
    -- converts
    --[[
    {
        ["unlockedChars"] = {
            true,
            true,
            false,
            ...,
        },
        ['lastChars'] = {
            "char1.png",
            "char2",
            ...
        }
    }
    
    to
    {
    -- unlocked, count
        ["unlockedChars"] = {
            {true, 10},
            {true, 1},
            {false, 2},
            ...,
        },
        ['lastChars'] = {
            "char1.png",
            "char2",
            ...
        }
    }
    ]]
    local newUnlockedChars = {}
    for i, unlocked in ipairs(save.unlockedChars) do
        if not newUnlockedChars[i] then
            newUnlockedChars[i] = {unlocked, 0}
        end
    end
    return {
        unlockedChars = newUnlockedChars,
        lastChars = save.lastChars or {},
    }
end

function Save.load(gacha)
    if love.filesystem.getInfo("save.lua") then
        local saveData = love.filesystem.load("save.lua")()
        if type(saveData) == "table" then
            if saveData.unlockedChars and type(saveData.unlockedChars[1]) ~= "table" then
                saveData = Save.migrateSave(saveData)
            end
            gacha.lastChars = saveData.lastChars or gacha.lastChars
            gacha.unlockedChars = saveData.unlockedChars or gacha.unlockedChars
        end
    end
end

function Save.save(gacha)
    local function indexer(key)
        if tonumber(key) then return "" else return "['" .. key .. "'] = " end
    end

    local function tableToString(tbl, indent)
        indent = indent or ""
        local str = "{"
        for k, v in pairs(tbl) do
            local keyStr = indexer(k)
            if type(v) == "table" then
                str = str .. "\n" .. indent .. keyStr .. tableToString(v, indent .. "  ") .. ","
            elseif type(v) == "string" then
                str = str .. "\n" .. indent .. keyStr .. "\"" .. v .. "\"," 
            else
                str = str .. "\n" .. indent .. keyStr .. tostring(v) .. ","
            end
        end
        str = str .. "\n" .. indent .. "}"
        return str
    end

    local saveData = {
        lastChars = gacha.lastChars,
        unlockedChars = gacha.unlockedChars
    }

    love.filesystem.write("save.lua", "return " .. tableToString(saveData, "  "))
end

return Save