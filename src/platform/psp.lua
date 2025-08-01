local Base = require("platform.base")

local PlatformPSP = setmetatable({}, { __index = Base })

function PlatformPSP:getFontSize()
    return 12
end

function PlatformPSP:getTweenPos()
    return {
        startX = 180, startY = 250,
        endX = love.graphics.getWidth() / 2-2, endY = 95
    }
end

return PlatformPSP
