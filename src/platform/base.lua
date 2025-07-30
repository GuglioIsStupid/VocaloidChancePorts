local BasePlatform = {}

function BasePlatform:init()
    if love.graphics.setDefaultFilter then
        love.graphics.setDefaultFilter("nearest", "nearest")
    end
end

function BasePlatform:getFontSize()
    return 8
end

function BasePlatform:getDepth(screen)
    return screen ~= "bottom" and -love.graphics.getDepth() or 0
end

function BasePlatform:getScale()
    return 1.0
end

function BasePlatform:getMode()
    return "720"
end

function BasePlatform:getTweenPos()
    return {
        startX = 0, startY = 0,
        endX = love.graphics.getWidth()/2, endY = 320
    }
end

return BasePlatform
