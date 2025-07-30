local Base = require("platform.base")
local gacha = require("systems.gacha")

local PlatformWiiU = setmetatable({}, { __index = Base })

function PlatformWiiU:getFontSize()
    return 18
end

function PlatformWiiU:getScale()
    return 1.75
end

function PlatformWiiU:getMode()
    return "720"
end

function PlatformWiiU:getTweenPos()
    if gacha.mergedScreens then
        if gacha.swappedScreens then
            return {
                startX = 323, startY = 440,
                endX = 429, endY = 205
            }
        else
            return {
                startX = 484, startY = 666,
                endX = 635, endY = 334
            }
        end
    else
        if gacha.swappedScreens then
            return {
                startX = 486, startY = 665,
                endX = 636, endY = 329
            }
        else
            return {
                startX = 486, startY = 665,
                endX = 636, endY = 329
            }
        end
    end
end

return PlatformWiiU
