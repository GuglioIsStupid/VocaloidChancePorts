local charData = require("data.chars")

local function drawBottomScreen(assets, chars, platform, gacha, screenW, screenH)
    love.graphics.draw(assets.bg, 0, 0)
    love.graphics.draw(assets.gachaMachine, (screenW - assets.gachaMachine:getWidth() * 1.5) / 2, (screenH - assets.gachaMachine:getHeight() * 1.5) / 2, 0, 1.5, 1.5)
    love.graphics.draw(assets.knob, gacha.knobCenter.x, gacha.knobCenter.y, gacha.knobRotation[1], 1.5, 1.5, assets.knob:getWidth() / 2, assets.knob:getHeight() / 2)

    love.graphics.draw(assets.flash, screenW/2, screenH/2 - 35, 0, gacha.flashScale[1] * 2, gacha.flashScale[1] * 2, assets.flash:getWidth()/2, assets.flash:getHeight()/2)

    if gacha.curPulledChar.show then
        local charQuad = chars[gacha.curPulledChar.img]
        if charQuad then
            local _, _, charWidth, charHeight = charQuad:getViewport()
            love.graphics.draw(assets.charSheet, charQuad, gacha.curPulledChar.x, gacha.curPulledChar.y, 0, 2, 2, charWidth / 2, charHeight / 2)
        end
        if gacha.showNew then
            love.graphics.draw(assets.newTag, gacha.curPulledChar.x + 20, gacha.curPulledChar.y - 35, 0, 1.5, 1.5)
        end
        if gacha.step == 1 then
            local idx = gacha.curPulledChar.id
            local name = charData[idx] and charData[idx].name or ""
            love.graphics.printf(name, 0, 142, screenW, "center")
        elseif gacha.step == 2 then
            love.graphics.printf(gacha.curRarity, 0, 142, screenW, "center")
        end
    end
end

local function drawTopScreen(assets, chars, platform, gacha, screenW, screenH, screen)
    local depth = platform:getDepth(screen)
    love.graphics.draw(assets.bg, 0, 0)
    love.graphics.draw(assets.last10, 0 - depth *2, 0, 0, 2, 2)
    print(screenW, screenH)

    local cols, spacing, scale = 5, 72, 2
    local gridWidth = cols * spacing
    local rows = math.ceil(#gacha.lastChars / cols)
    local gridHeight = rows * spacing
    local offsetX = (screenW - gridWidth) / 2
    local offsetY = (screenH - gridHeight) / 2
    for i = #gacha.lastChars, 1, -1 do
            local char = gacha.lastChars[i]
            local quad = chars[char]
            if quad then
                local reverseIndex = #gacha.lastChars - i
                local col = reverseIndex % cols
                local row = math.floor(reverseIndex / cols)
                local x = col * spacing + offsetX
                local y = row * spacing + offsetY
                print(x, y)
                love.graphics.draw(assets.charSheet, quad, x - depth * 3, y, 0, scale, scale)
            end
        end
end

local function drawSwitchScreen(assets, chars, platform, gacha, screenW, screenH, screen)
    love.graphics.draw(assets.bg, 0, 0, 0, 3.2, 3.2)

    love.graphics.draw(assets.gachaMachine, (screenW - assets.gachaMachine:getWidth() * 3.2) / 2-75, (screenH - assets.gachaMachine:getHeight() * 3.2) / 2, 0, 3.85, 3.85)

    love.graphics.draw(assets.knob, gacha.knobCenter.x, gacha.knobCenter.y, gacha.knobRotation[1], 3.85, 3.85, assets.knob:getWidth() / 2, assets.knob:getHeight() / 2)

    love.graphics.draw(assets.last10, 0, 0, 0, 3.2, 3.2)

    local cols, spacing, scale = 2, 122, 3
    local rows = math.ceil(#gacha.lastChars / cols)
    local offsetX = 25
    local offsetY = 100
    for i = #gacha.lastChars, 1, -1 do
        local char = gacha.lastChars[i]
        local quad = chars[char]
        if quad then
            local reverseIndex = #gacha.lastChars - i
            local col = reverseIndex % cols
            local row = math.floor(reverseIndex / cols)
            local x = col * spacing + offsetX
            local y = row * spacing + offsetY
            love.graphics.draw(assets.charSheet, quad, x, y, 0, scale, scale)
        end
    end

    love.graphics.draw(assets.flash, screenW/2, screenH/2 - 35, 0, gacha.flashScale[1] * 3.85, gacha.flashScale[1] * 3.85, assets.flash:getWidth()/2, assets.flash:getHeight()/2)

    if gacha.curPulledChar.show then
        local charQuad = chars[gacha.curPulledChar.img]
        if charQuad then
            local _, _, charWidth, charHeight = charQuad:getViewport()
            love.graphics.draw(assets.charSheet, charQuad, gacha.curPulledChar.x, gacha.curPulledChar.y, 0, 3.3, 3.3, charWidth / 2, charHeight / 2)
        end
        if gacha.showNew then
            love.graphics.draw(assets.newTag, gacha.curPulledChar.x + 20, gacha.curPulledChar.y - 65, 0, 3.33, 3.33)
        end
        if gacha.step == 1 then
            local idx = gacha.curPulledChar.id
            local name = charData[idx] and charData[idx].name or ""
            love.graphics.printf(name, 0, 475, screenW, "center")
        elseif gacha.step == 2 then
            love.graphics.printf(gacha.curRarity, 0, 475, screenW, "center")
        end
    end
end

local function drawWiiUScreen(screen, assets, chars, platform, gacha, screenW, screenH)
    if ((not gacha.swappedScreens and screen == "gamepad") or (gacha.swappedScreens and screen == "tv")) and not gacha.mergedScreens then
        love.graphics.draw(assets.bg, 0, 0, 0, 3.2, 3.2)
        local scale = 3.85 - (screen == "gamepad" and 1.25 or 0)
        local x = (screenW - assets.gachaMachine:getWidth() * 3.2) / 2 - 75 + (screen == "gamepad" and 155 or 0)
        local y = (screenH - assets.gachaMachine:getHeight() * 3.2) / 2 + (screen == "gamepad" and 80 or 0)
        love.graphics.draw(assets.gachaMachine, x, y, 0, scale, scale)
        local knobX = gacha.knobCenter.x - (screen == "gamepad" and 98*2+11 or 0)
        local knobY = gacha.knobCenter.y - (screen == "gamepad" and 107*2-6 or 0)
        local knobScale = 3.85 - (screen == "gamepad" and 1 or 0)
        love.graphics.draw(assets.knob, knobX, knobY, gacha.knobRotation[1], knobScale, knobScale, assets.knob:getWidth() / 2, assets.knob:getHeight() / 2)
        local flashX = screenW / 2 + (screen == "gamepad" and 0 or 0)
        local flashY = screenH / 2 - 35 + (screen == "gamepad" and 0 or 0)
        love.graphics.draw(assets.flash, flashX, flashY, 0, gacha.flashScale[1] * 2.2, gacha.flashScale[1] * 2.2, assets.flash:getWidth()/2, assets.flash:getHeight()/2)

        if gacha.curPulledChar.show then
            local charQuad = chars[gacha.curPulledChar.img]
            if charQuad then
                local _, _, charWidth, charHeight = charQuad:getViewport()
                local pulledX = gacha.curPulledChar.x - (screen == "gamepad" and 215 or 0)
                local pulledY = gacha.curPulledChar.y - (screen == "gamepad" and 120 or 0)
                love.graphics.draw(assets.charSheet, charQuad, pulledX, pulledY, 0, 2.2, 2.2, charWidth / 2, charHeight / 2)
            end
            if gacha.showNew then
                local newX = gacha.curPulledChar.x + 20 - (screen == "gamepad" and 215 or 0)
                local newY = gacha.curPulledChar.y - 45 - (screen == "gamepad" and 120 or 0)
                love.graphics.draw(assets.newTag, newX, newY, 0, 2.2, 2.2)
            end
            if gacha.step == 1 then
                local idx = gacha.curPulledChar.id
                local name = charData[idx] and charData[idx].name or ""
                love.graphics.printf(name, 0, screenH - 120, screenW, "center")
            elseif gacha.step == 2 then
                love.graphics.printf(gacha.curRarity, 0, screenH - 120, screenW, "center")
            end
        end
    elseif ((not gacha.swappedScreens and screen == "tv") or (gacha.swappedScreens and screen == "gamepad")) and not gacha.mergedScreens then
        print("Drawing TV/Gamepad Screen")
        local depth = platform.getDepth and platform:getDepth(screen) or 0
        love.graphics.draw(assets.bg, 0, 0, 0, 3.2, 3.2)
        love.graphics.draw(assets.last10, 0 - depth * 2, 0, 0, 2.2, 2.2)

        local cols, spacing, scale = 5, 122, 3
        local gridWidth = cols * spacing
        local rows = math.ceil(#gacha.lastChars / cols)
        local gridHeight = rows * spacing
        local offsetX = (screenW - gridWidth) / 2
        local offsetY = (screenH - gridHeight) / 2

        for i = #gacha.lastChars, 1, -1 do
            local char = gacha.lastChars[i]
            local quad = chars[char]
            if quad then
                local reverseIndex = #gacha.lastChars - i
                local col = reverseIndex % cols
                local row = math.floor(reverseIndex / cols)
                local x = col * spacing + offsetX
                local y = row * spacing + offsetY
                love.graphics.draw(assets.charSheet, quad, x - depth * 3, y, 0, scale, scale)
            end
        end
    else
        if gacha.mergedScreens and ((not gacha.swappedScreens and screen == "tv") or (gacha.swappedScreens and screen == "gamepad")) then
            love.graphics.draw(assets.bg, 0, 0, 0, 3.2, 3.2)
            if screen == "gamepad" then
                love.graphics.scale(0.8, 0.8)
            end
            love.graphics.draw(assets.last10, 0, 0, 0, 3.2, 3.2)

            local cols, spacing, scale = 2, 122 - (screen == "gamepad" and 20 or 0), 3 - (screen == "gamepad" and 0.5 or 0)
            local rows = math.ceil(#gacha.lastChars / cols)
            local offsetX = 25
            local offsetY = 100 - (screen == "gamepad" and 50 or 0)
            for i = #gacha.lastChars, 1, -1 do
                local char = gacha.lastChars[i]
                local quad = chars[char]
                if quad then
                    local reverseIndex = #gacha.lastChars - i
                    local col = reverseIndex % cols
                    local row = math.floor(reverseIndex / cols)
                    local x = col * spacing + offsetX
                    local y = row * spacing + offsetY
                    love.graphics.draw(assets.charSheet, quad, x, y, 0, scale, scale)
                end
            end


            local scale = 3.85 - (screen == "gamepad" and 0.5 or 0)
            local x = (screenW - assets.gachaMachine:getWidth() * 3.2) / 2 - 75 + (screen == "gamepad" and 175 or 0)
            local y = (screenH - assets.gachaMachine:getHeight() * 3.2) / 2 + (screen == "gamepad" and 80 or 0)
            love.graphics.draw(assets.gachaMachine, x, y, 0, scale, scale)

            local knobX = gacha.knobCenter.x - (screen == "gamepad" and 98 or 0)
            local knobY = gacha.knobCenter.y - (screen == "gamepad" and 107 or 0)
            local knobScale = 3.85 - (screen == "gamepad" and 0.25 or 0)
            love.graphics.draw(assets.knob, knobX, knobY, gacha.knobRotation[1], knobScale, knobScale, assets.knob:getWidth() / 2, assets.knob:getHeight() / 2)

            local flashX = screenW / 2 + (screen == "gamepad" and 115 or 0)
            local flashY = screenH / 2 - 35 + (screen == "gamepad" and 40 or 0)

            love.graphics.draw(assets.flash, flashX, flashY, 0, gacha.flashScale[1] * 3.85, gacha.flashScale[1] * 3.85, assets.flash:getWidth()/2, assets.flash:getHeight()/2)

            if gacha.curPulledChar.show then
                local charQuad = chars[gacha.curPulledChar.img]
                if charQuad then
                    local _, _, charWidth, charHeight = charQuad:getViewport()
                    local pulledX = gacha.curPulledChar.x + (screen == "gamepad" and 105 or 0)
                    local pulledY = gacha.curPulledChar.y + (screen == "gamepad" and 45 or 0)
                    love.graphics.draw(assets.charSheet, charQuad, pulledX, pulledY, 0, 3.3, 3.3, charWidth / 2, charHeight / 2)
                end
                if gacha.showNew then
                    love.graphics.draw(assets.newTag, gacha.curPulledChar.x + 20, gacha.curPulledChar.y - 65, 0, 3.33, 3.33)
                end
                if gacha.step == 1 then
                    local idx = gacha.curPulledChar.id
                    local name = charData[idx] and charData[idx].name or ""
                    local x = screen == "gamepad" and 110 or 0
                    local y = screenH - 244 + (screen == "gamepad" and 150 or 0)
                    love.graphics.printf(name, x, y, screenW, "center")
                elseif gacha.step == 2 then
                    local x = screen == "gamepad" and 110 or 0
                    local y = screenH - 244 + (screen == "gamepad" and 150 or 0)
                    love.graphics.printf(gacha.curRarity, x, y, screenW, "center")
                end
            end

            if screen == "gamepad" then
                love.graphics.scale(1 / 0.8, 1 / 0.8)
            end
        end
    end
end

local function drawPSPScreen(assets, chars, platform, gacha, screenW, screenH, screen)
    love.graphics.draw(assets.bg, 0, 0, 0, 1.265, 1.265)
    love.graphics.draw(assets.gachaMachine, 70, 40, 0, 1.45, 1.45)
    love.graphics.draw(assets.knob, gacha.knobCenter.x, gacha.knobCenter.y, gacha.knobRotation[1], 1.45, 1.45, assets.knob:getWidth() / 2, assets.knob:getHeight() / 2)

    love.graphics.draw(assets.flash, screenW/2, screenH/2 - 35, 0, gacha.flashScale[1] * 1.45, gacha.flashScale[1] * 1.45, assets.flash:getWidth()/2, assets.flash:getHeight()/2)

    if gacha.curPulledChar.show then
        local charImage = chars[gacha.curPulledChar.img]
        if charImage then
            love.graphics.draw(charImage, gacha.curPulledChar.x, gacha.curPulledChar.y, 0, 1.45, 1.45, charImage:getWidth() / 2, charImage:getHeight() / 2)
        end
        if gacha.showNew then
            love.graphics.draw(assets.newTag, gacha.curPulledChar.x + 20, gacha.curPulledChar.y - 35, 0, 1.5, 1.5)
        end
        if gacha.step == 1 then
            local idx = gacha.curPulledChar.id
            local name = charData[idx] and charData[idx].name or ""
            love.graphics.printf(name, 0, screenH - 92, screenW, "center")
        elseif gacha.step == 2 then
            love.graphics.printf(gacha.curRarity, 0, screenH - 92, screenW, "center")
        end
    end

    love.graphics.draw(assets.last10, 0, 0, 0, 1.45, 1.45)

    local cols, spacing, scale = 2, 33, 1.45
    local rows = math.ceil(#gacha.lastChars / cols)
    local offsetX = 5
    local offsetY = 20
    for i = #gacha.lastChars, 1, -1 do
        local char = gacha.lastChars[i]
        local quad = chars[char]
        if quad then
            local reverseIndex = #gacha.lastChars - i
            local col = reverseIndex % cols
            local row = math.floor(reverseIndex / cols)
            local x = col * (spacing*scale) + offsetX
            local y = row * (spacing*scale) + offsetY
            love.graphics.draw(quad, x, y, 0, scale, scale)
        end
    end
end

local Draw = {}

function Draw.render(screen, ctx)
    local w, h = love.graphics.getDimensions(screen)
    local console = love._console
    if console == "3DS" then
        if screen == "bottom" then
            drawBottomScreen(ctx.assets, ctx.chars, ctx.platform, ctx.gacha, w, h)
        else
            drawTopScreen(ctx.assets, ctx.chars, ctx.platform, ctx.gacha, w, h, screen)
        end
    elseif console == "Wii U" then
        drawWiiUScreen(screen, ctx.assets, ctx.chars, ctx.platform, ctx.gacha, w, h)
    elseif console == "PSP" then
        drawPSPScreen(ctx.assets, ctx.chars, ctx.platform, ctx.gacha, w, h, screen)
    else
        drawSwitchScreen(ctx.assets, ctx.chars, ctx.platform, ctx.gacha, w, h, screen)
    end
end

return Draw