local Base = require("platform.base")

local Platform3DS = setmetatable({}, { __index = Base })

function Platform3DS:getFontSize()
    return 14
end

function Platform3DS:getTweenPos()
    return {
        startX = 99, startY = 217,
        endX = love.graphics.getWidth("bottom") / 2-2, endY = 82
    }
end

return Platform3DS
