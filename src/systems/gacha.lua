---@diagnostic disable: undefined-field
local Timer = require("lib.timer")

local Gacha = {
    assets = nil,
    chars = nil,
    knobCenter = nil,

    crankStep = 0,
    step = 0,
    pulled = false,
    isTurning = false,
    touchId = nil,
    allowInput = true,
    totalRotation = 0,
    lastAngle = nil,

    curPulledChar = { img = "char0.png", x = 99, y = 217, id = 0, show = false },
    flashScale = { 0 },
    showNew = false,
    isNew = false,
    curRarity = "COMMON",

    unlockedChars = {},
    lastChars = {},
    knobRotation = { 0 },
    Platform = nil,
    swappedScreens = false,
    mergedScreens = false
}

local crank = love.audio.newSource("assets/crank.ogg", "static")
local ding = love.audio.newSource("assets/ding.ogg", "static")

local indexRarities = {
    common   = {1, 2, 3, 4, 5, 6},
    uncommon = {7, 8, 9, 10},
    rare     = {11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35,
                36, 37, 39, 40, 41, 42, 48, 49, 50, 51, 53, 55, 56, 57, 58, 59, 60},
    mythical = {38, 43, 44, 45, 46, 47, 52, 54},
}

local rarities = {
    { name = "COMMON",    min = 1,  max = 50,  pool = "common" },
    { name = "UNCOMMON",  min = 51, max = 75,  pool = "uncommon" },
    { name = "RARE",      min = 76, max = 95,  pool = "rare" },
    { name = "MYTHICAL!", min = 96, max = 100, pool = "mythical" },
}

function Gacha.init(config)
    Gacha.assets = config.assets
    Gacha.chars = config.chars
    Gacha.knobCenter = config.knobCenter
    Gacha.platform = config.platform

    for i = 1, 10 do Gacha.lastChars[i] = "char0.png" end
    for i = 1, 60 do Gacha.unlockedChars[i] = {false, 0} end
end

local function audioPlay(source)
    if not source:isPlaying() then
        source:play()
    end
end

local function pullCharacter()
    local roll = love.math.random(1, 100)
    for _, rarity in ipairs(rarities) do
        if roll >= rarity.min and roll <= rarity.max then
            local pool = indexRarities[rarity.pool]
            local idx = pool[love.math.random(#pool)]
            return idx, rarity.name
        end
    end
end

local function finishAnimation()
    local pos = Gacha.platform:getTweenPos()
    Gacha.curPulledChar.x = pos.startX
    Gacha.curPulledChar.y = pos.startY
    Timer.tween(0.1, Gacha.curPulledChar, {x = pos.endX, y = pos.endY}, "linear", function()
        Gacha.curPulledChar.x = pos.endX
        Gacha.curPulledChar.y = pos.endY
    end)
end

local function triggerPull()
    if not Gacha.allowInput then return end
    Gacha.crankStep = 1
    Timer.tween(0.5, Gacha.knobRotation, { math.rad(360) }, "linear", function()
        Gacha.knobRotation[1] = 0
        local index, rarity = pullCharacter()
        Gacha.curPulledChar.img = "char" .. index .. ".png"
        Gacha.curPulledChar.x = 99
        Gacha.curPulledChar.y = 217
        Gacha.curPulledChar.id = index
        Gacha.curPulledChar.show = true
        Gacha.curRarity = rarity

        Gacha.isNew = not Gacha.unlockedChars[index][1]
        Gacha.unlockedChars[index][1] = true
        Gacha.unlockedChars[index][2] = Gacha.unlockedChars[index][2] + 1

        table.insert(Gacha.lastChars, "char" .. index .. ".png")
        if #Gacha.lastChars > 10 then table.remove(Gacha.lastChars, 1) end

        audioPlay(ding)
        finishAnimation()
    end)
    Timer.after(0.1, function()
        Gacha.crankStep = 2
        Timer.after(0.25, function()
            Gacha.crankStep = 3
            Timer.after(0.45, function()
                Gacha.showNew = Gacha.isNew
            end)
        end)
    end)
end

function Gacha.update(dt)
    if Gacha.crankStep == 1 and not crank:isPlaying() then
        Gacha.allowInput = false
        audioPlay(crank)
    elseif Gacha.crankStep == 2 then
        audioPlay(crank)
    elseif Gacha.crankStep == 3 then
        audioPlay(crank)
        Gacha.crankStep = 0
        Timer.tween(0.5, Gacha.flashScale, {1.2}, "out-back", function()
            Gacha.flashScale = {1.2}
            Gacha.allowInput = true
            Gacha.step = 1
        end)
    end
end

function Gacha.touchpressed(id, x, y)
    if Gacha.pulled or not Gacha.allowInput or Gacha.step > 0 then
        if not Gacha.isTurning then
            Gacha.step = Gacha.step + 1
            if Gacha.step > 2 then
                Gacha.flashScale = {0}
                Gacha.step = 0
                Gacha.curPulledChar.show = false
                Gacha.pulled = false
                Gacha.showNew = false
            end
        end
        return
    end
    local dx, dy = x - Gacha.knobCenter.x, y - Gacha.knobCenter.y
    if math.sqrt(dx * dx + dy * dy) < 40 then
        Gacha.isTurning, Gacha.touchId = true, id
        Gacha.lastAngle, Gacha.totalRotation = math.atan2(dy, dx), 0
    end
end

function Gacha.touchmoved(id, x, y)
    if Gacha.pulled or not (Gacha.isTurning and id == Gacha.touchId) or not Gacha.allowInput or Gacha.step > 0 then return end
    audioPlay(crank)
    local dx, dy = x - Gacha.knobCenter.x, y - Gacha.knobCenter.y
    local angle = math.atan2(dy, dx)
    local delta = angle - Gacha.lastAngle
    if delta > math.pi then delta = delta - 2 * math.pi end
    if delta < -math.pi then delta = delta + 2 * math.pi end

    Gacha.totalRotation = Gacha.totalRotation + math.abs(delta)
    Gacha.knobRotation[1] = (Gacha.knobRotation[1] + delta) % (2 * math.pi)
    Gacha.lastAngle = angle

    if Gacha.totalRotation >= 2 * math.pi then
        Gacha.isTurning, Gacha.touchId = false, nil
        triggerPull()
        Gacha.pulled = true
    end
end

function Gacha.touchreleased(id)
    if id ~= Gacha.touchId or not Gacha.allowInput or Gacha.step > 0 then return end
    Gacha.isTurning, Gacha.touchId, Gacha.lastAngle = false, nil, nil
    if Gacha.totalRotation < 2 * math.pi then
        Timer.tween(0.5, Gacha.knobRotation, {0}, "out-back", function()
            Gacha.knobRotation[1] = 0
        end)
    end
    Gacha.totalRotation = 0
end

function Gacha.keypressed(k)
    if k == "z" and not Gacha.pulled and Gacha.allowInput and Gacha.step == 0 then
        triggerPull()
        Gacha.pulled = true
    elseif k == "z" and Gacha.allowInput and Gacha.step ~= 0 and not Gacha.isTurning then
        Gacha.step = Gacha.step + 1
        if Gacha.step > 2 then
            Gacha.flashScale = {0}
            Gacha.step = 0
            Gacha.curPulledChar.show = false
            Gacha.pulled = false
            Gacha.showNew = false
        end
    elseif k == "r" then
        Gacha.reset()
    end
end

function Gacha.gamepadpressed(joystick, button)
    if button == "a" and not Gacha.pulled and Gacha.allowInput and Gacha.step == 0 then
        triggerPull()
        Gacha.pulled = true
    elseif button == "a" and Gacha.allowInput and Gacha.step ~= 0 and not Gacha.isTurning then
        Gacha.step = Gacha.step + 1
        if Gacha.step > 2 then
            Gacha.flashScale = {0}
            Gacha.step = 0
            Gacha.curPulledChar.show = false
            Gacha.pulled = false
            Gacha.showNew = false
        end
    elseif button == "back" then
        if joystick:isGamepadDown("rightshoulder") then
            Gacha.swappedScreens = not Gacha.swappedScreens
        else
            Gacha.mergedScreens = not Gacha.mergedScreens
        end
    elseif button == "b" then
        Gacha.reset()
    end
end

function Gacha.reset()
    Gacha.knobRotation = {0}
    Gacha.totalRotation = 0
    Gacha.pulled = false
    Gacha.curPulledChar.show = false
end

return Gacha
