local assets = {}

function assets.load(platform)
    local scale = platform:getScale()
    local input = "A"
    if love._console == "PSP" then
        input = "X"
    end
    return {
        bg = love.graphics.newImage("assets/gachabg.png"),
        charSheet = love._console ~= "PSP" and love.graphics.newImage("assets/charSheet.png") or nil,
        gachaMachine = love.graphics.newImage("assets/gachamachine" .. input .. ".png"),
        last10 = love.graphics.newImage("assets/last10.png"),
        knob = love.graphics.newImage("assets/knob.png"),
        flash = love.graphics.newImage("assets/Flash.png"),
        newTag = love.graphics.newImage("assets/NEW.png"),
        scale = scale,
    }
end

function assets.loadCharQuads(charSheet)
    local chars = {}
    for line in love.filesystem.lines("assets/charSheet.txt") do
        local name, x, y, w, h = line:match("(.+) (%d+) (%d+) (%d+) (%d+)")
        if name then
            chars[name] = love.graphics.newQuad(tonumber(x), tonumber(y), tonumber(w), tonumber(h), charSheet:getDimensions())
        end
    end
    return chars
end

function assets.loadChars()
    -- load all chars in assets/chars/
    local chars = {}
    for i = 0, 60 do
        chars["char" .. i .. ".png"] = love.graphics.newImage("assets/chars/char" .. i .. ".png")
    end

    return chars
end

return assets
