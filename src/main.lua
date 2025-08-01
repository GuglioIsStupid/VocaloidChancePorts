local Timer = require("lib.timer")
local platformModules = {
    ["3DS"] = "platform.3ds",
    ["Wii U"] = "platform.wiiu",
    ["Switch"] = "platform.switch",
    ["PSP"] = "platform.psp"
}
local isDesktop = false
if love.system.getOS() == "Windows" or love.system.getOS() == "Linux" or love.system.getOS() == "macOS" then
    isDesktop = true
end
local nest
if isDesktop then
    nest = require("lib.nest").init({ console = "3ds", scale = 1 })
end

local os = love._console
function love.graphics.getWidth(screen)
    if os == "3DS" then
        if screen == "top" then
            return 400
        elseif screen == "bottom" then
            return 320
        else
            return 400
        end
    elseif os == "Switch" or os == "Wii U" then
        return 1280
    elseif os == "PSP" then
        return 480
    end

    return 1280
end

function love.graphics.getHeight(screen)
    if os == "3DS" then
        if screen == "top" then
            return 240
        elseif screen == "bottom" then
            return 320
        else
            return 240
        end
    elseif os == "Switch" or os == "Wii U" then
        return 720
    elseif os == "PSP" then
        return 270
    end

    return 720
end

function love.graphics.getDimensions(screen)
    if os == "3DS" then
        if screen == "top" then
            return 400, 240
        elseif screen == "bottom" then
            return 320, 240
        else
            return 400, 240
        end
    elseif os == "Switch" or os == "Wii U" then
        return 1280, 720
    elseif os == "PSP" then
        return 480, 270
    end

    return 1280, 720
end

local currentConsole = love._console
print("Current console detected: " .. currentConsole)
local Platform = require(platformModules[currentConsole])

local Assets = require("systems.assets")
local Gacha = require("systems.gacha")
local Save = require("systems.save")
local Draw = require("systems.draw")
love.graphics.getDepth = love.graphics.getDepth or function() return 0 end -- Fallback for platforms without getDepth

local assets, chars
local knobCenter = { x = 0, y = 0 }

function love.load()
    Platform:init()

    local fontSize = Platform:getFontSize()
    love.graphics.setFont(love.graphics.newFont("assets/pixearg.ttf", fontSize))

    assets = Assets.load(Platform)
    if love._console == "PSP" then
        chars = Assets.loadChars()
    else
        chars = Assets.loadCharQuads(assets.charSheet)
    end

    local w, h = love.graphics.getDimensions("bottom")

    if love._console == "3DS" then
        knobCenter.x = w / 2 - 1
        knobCenter.y = h / 2 + 81
    elseif love._console == "Switch" then
        knobCenter.x = w / 2
        knobCenter.y = h / 2 + 260
    elseif love._console == "Wii U" then
        knobCenter.x = w / 2
        knobCenter.y = h / 2 + 260
    elseif love._console == "PSP" then
        knobCenter.x = w / 2 + 3
        knobCenter.y = h / 2 + 100
    end

    Gacha.init({
        assets = assets,
        chars = chars,
        knobCenter = knobCenter,
        platform = Platform,
    })

    Save.load(Gacha)
end

function love.update(dt)
    Timer.update(dt)
    Gacha.update(dt)
end

function love.draw(screen)
    Draw.render(screen, {
        assets = assets,
        chars = chars,
        knobCenter = knobCenter,
        gacha = Gacha,
        platform = Platform,
    })
end

function love.touchpressed(...) print(...)  Gacha.touchpressed(...)   end
function love.touchmoved(...)     Gacha.touchmoved(...)     end
function love.touchreleased(...)  Gacha.touchreleased(...)  end
function love.gamepadpressed(...)
    Gacha.gamepadpressed(...)

    local k = select(2, ...)
    if k == "start" then
        love.event.quit()
    end
end

function love.keypressed(k)
    Gacha.keypressed(k)
    ---@diagnostic disable-next-line: need-check-nil
    if isDesktop then
    ---@diagnostic disable-next-line: need-check-nil
        nest.video.keypressed(k)
    end
end

function love.quit()
    Save.save(Gacha)
end
