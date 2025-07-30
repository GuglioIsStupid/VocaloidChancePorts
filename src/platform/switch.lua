local Base = require("platform.base")

local PlatformSwitch = setmetatable({}, { __index = Base })

function PlatformSwitch:getFontSize()
    return 20
end

function PlatformSwitch:getScale()
    return 2.0
end

function PlatformSwitch:getMode()
    return "1080"
end

function PlatformSwitch:getTweenPos()
    return {
        startX = 484, startY = 664,
        endX = love.graphics.getWidth()/2, endY = 320
    }
end

return PlatformSwitch
