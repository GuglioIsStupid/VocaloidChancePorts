local assets = {}

function assets.load(platform)
    local scale = platform:getScale()

    return {
        bg = love.graphics.newImage("assets/gachabg.png"),
        charSheet = love.graphics.newImage("assets/charSheet.png"),
        gachaMachine = love.graphics.newImage("assets/gachamachineA.png"),
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

return assets
