local nest = require("lib.nest").init({ console = "3ds", scale = 1, mode = "720" })
local Timer = require("lib.timer")

if love.graphics.setDefaultFilter then
    love.graphics.setDefaultFilter("nearest", "nearest")
end

love.filesystem.lines = love.filesystem.lines or function(filename)
    local file = love.filesystem.read(filename)
    local lines = {}
    for line in file:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    return lines
end

local charData = require("data.chars")

local bg, charSheet, chars, gachaMachine, last10, knob, flash
local crank, ding = love.audio.newSource("assets/crank.ogg", "static"), love.audio.newSource("assets/ding.ogg", "static")

local knobCenter = { x = 0, y = 0 }
local knobRotation = { 0 }
local pulled, isTurning, touchId = false, false, nil
local totalRotation, lastAngle = 0, nil
local allowInput = true

local lastChars = {}
for i = 1, 10 do lastChars[i] = "char0.png" end
local unlockedChars = {}
for i = 1, 60 do
    unlockedChars[i] = false
end

if love.filesystem.getInfo("save.lua") then
    local saveData = love.filesystem.load("save.lua")()
    if type(saveData) == "table" then
        lastChars = saveData.lastChars or lastChars
        unlockedChars = saveData.unlockedChars or unlockedChars
    end
end

local indexRarites = {
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

local curPulledChar = {img = "char0.png", x = 99, y = 217, id = 0, show = false}
local curRarity = "COMMON"
local step = 0
local crankStep = 0
local flashScale = {0}
local showNew = false
local isNew = false

local function getDepth(screen)
	local depth = screen ~= "bottom" and -love.graphics.getDepth() or 0
	if screen == "right" then
		depth = -depth
	end
	return depth
end

local function audioPlay(source)
    --[[ if source:isPlaying() and source:tell() > 0.1 then
        source:stop()
    end ]]
    source:play()
end

function string:strip() return self:match("^%s*(.-)%s*$") end

local function pullCharacter()
    local rarityRoll = love.math.random(1, 100)
    local charIndex
    local rarityLabel

    if rarityRoll >= 1 and rarityRoll <= 50 then
        charIndex = indexRarites.common[love.math.random(#indexRarites.common)]
        rarityLabel = "COMMON"
    elseif rarityRoll >= 51 and rarityRoll <= 75 then
        charIndex = indexRarites.uncommon[love.math.random(#indexRarites.uncommon)]
        rarityLabel = "UNCOMMON"
    elseif rarityRoll >= 76 and rarityRoll <= 95 then
        charIndex = indexRarites.rare[love.math.random(#indexRarites.rare)]
        rarityLabel = "RARE"
    elseif rarityRoll >= 96 and rarityRoll <= 100 then
        charIndex = indexRarites.mythical[love.math.random(#indexRarites.mythical)]
        rarityLabel = "MYTHICAL!"
    end

    if #lastChars >= 10 then
        table.remove(lastChars, 1)
    end
    table.insert(lastChars, "char" .. charIndex .. ".png")

    pulled = true

    return charIndex, rarityLabel
end

local function resetGacha()
    knobRotation = {0}
    totalRotation = 0
    pulled = false
    curPulledChar.show = false
end

local function finishAnimation()
    Timer.tween(0.1, curPulledChar, {x = love.graphics.getWidth("bottom") / 2-2, y = 82}, "linear")
end

local function triggerPull()
    if not allowInput then return end
    crankStep = 1
    Timer.tween(0.5, knobRotation, { math.rad(360) }, "linear", function()
        knobRotation[1] = 0
        local index, rarity = pullCharacter()
        curPulledChar.img = "char" .. index .. ".png"
        curPulledChar.x = charData[index].x or 99
        curPulledChar.y = charData[index].y or 217
        curPulledChar.id = index
        curPulledChar.show = true
        curRarity = rarity

        isNew = not unlockedChars[index]
        unlockedChars[index] = true
        audioPlay(ding)
        finishAnimation()
    end)
    Timer.after(0.1, function()
        crankStep = 2
        Timer.after(0.25, function()
            crankStep = 3
            Timer.after(0.45, function()
                showNew = isNew
            end)
        end)
    end)
end

function love.load()
    bg = love.graphics.newImage("assets/gachabg.png")
    charSheet = love.graphics.newImage("assets/charSheet.png")
    gachaMachine = love.graphics.newImage("assets/gachamachineA.png")
    last10 = love.graphics.newImage("assets/last10.png")
    knob = love.graphics.newImage("assets/knob.png")
    flash = love.graphics.newImage("assets/Flash.png")
    NEW = love.graphics.newImage("assets/NEW.png")

    chars = {}
    for line in love.filesystem.lines("assets/charSheet.txt") do
        local name, x, y, w, h = line:match("(.+) (%d+) (%d+) (%d+) (%d+)")
        if name then
            chars[name] = love.graphics.newQuad(tonumber(x), tonumber(y), tonumber(w), tonumber(h), charSheet:getDimensions())
        end
    end

    local w, h = love.graphics.getDimensions("bottom")
    knobCenter.x = w / 2 - 1
    knobCenter.y = h / 2 + 81

    love.graphics.setFont(love.graphics.newFont("assets/pixearg.ttf", 7))
end

function love.update(dt)
    Timer.update(dt)

    if crankStep == 1 and not crank:isPlaying() then
        allowInput = false
        audioPlay(crank)
    elseif crankStep == 2 then
        audioPlay(crank)
    elseif crankStep == 3 then
        audioPlay(crank)
        crankStep = 0
        Timer.tween(0.5, flashScale, { 1.2 }, "out-back", function()
            allowInput = true
            step = 1
        end)
    end
end

function love.touchpressed(id, x, y)
    if pulled or not allowInput or step > 0 then
        if not isTurning then
            step = step + 1
            if step > 2 then
                flashScale = {0}
                step = 0
                curPulledChar.show = false
                pulled = false
                showNew = false
            end
        end
        return
    end
    local dx, dy = x - knobCenter.x, y - knobCenter.y
    if math.sqrt(dx * dx + dy * dy) < 40 then
        isTurning, touchId = true, id
        lastAngle, totalRotation = math.atan2(dy, dx), 0
    end
end

function love.touchmoved(id, x, y)
    if pulled or not (isTurning and id == touchId) or not allowInput or step > 0 then return end
    audioPlay(crank)

    local dx, dy = x - knobCenter.x, y - knobCenter.y
    local angle = math.atan2(dy, dx)
    local delta = angle - lastAngle

    if delta > math.pi then delta = delta - 2 * math.pi
    elseif delta < -math.pi then delta = delta + 2 * math.pi end

    totalRotation = totalRotation + math.abs(delta)
    knobRotation[1] = (knobRotation[1] + delta) % (2 * math.pi)
    lastAngle = angle

    if totalRotation >= 2 * math.pi then
        isTurning, touchId = false, nil
        triggerPull()
    end
end

function love.touchreleased(id)
    if id ~= touchId or not allowInput or step > 0 then return end
    isTurning, touchId, lastAngle = false, nil, nil

    if totalRotation < 2 * math.pi then
        Timer.tween(0.5, knobRotation, { 0 }, "out-back")
    end
    totalRotation = 0
end

function love.keypressed(k)
    if k == "z" and not pulled and allowInput and step == 0 then
        triggerPull()
    elseif k == "z" and allowInput and step ~= 0 and not isTurning then
        step = step + 1
        if step > 2 then
            flashScale = {0}
            step = 0
            curPulledChar.show = false
            pulled = false
            showNew = false
        end
    elseif k == "r" then
        resetGacha()
    end
    nest.video.keypressed(k)
end

function love.gamepadpressed(_, button)
    if button == "a" and not pulled and allowInput and step == 0 then
        triggerPull()
    elseif button == "a" and allowInput and step ~= 0 and not isTurning then
        step = step + 1
        if step > 2 then
            flashScale = {0}
            step = 0
            curPulledChar.show = false
            pulled = false
            showNew = false
        end
    elseif button == "b" then
        resetGacha()
    end
end

function love.wheelmoved(x, y)
    nest.video.wheelmoved(x, y)
end

function love.draw(screen)
    local w, h = love.graphics.getDimensions(screen)
    if screen == "bottom" then
        love.graphics.draw(bg, 0, 0)
        love.graphics.draw(gachaMachine, (w - gachaMachine:getWidth() * 1.5) / 2, (h - gachaMachine:getHeight() * 1.5) / 2, 0, 1.5, 1.5)
        love.graphics.draw(knob, knobCenter.x, knobCenter.y, knobRotation[1], 1.5, 1.5, knob:getWidth() / 2, knob:getHeight() / 2)

        love.graphics.draw(flash, w/2, h/2 - 35, 0, flashScale[1] * 2, flashScale[1] * 2, flash:getWidth()/2, flash:getHeight()/2)

        if curPulledChar.show then
            local charQuad = chars[curPulledChar.img]
            if charQuad then
                local _, _, charWidth, charHeight = charQuad:getViewport()
                love.graphics.draw(charSheet, charQuad, curPulledChar.x, curPulledChar.y, 0, 2, 2, charWidth / 2, charHeight / 2)
            end
            if showNew then
                love.graphics.draw(NEW, curPulledChar.x + 20, curPulledChar.y - 35, 0, 1.5, 1.5)
            end

            if step == 1 then
                local charIndex = curPulledChar.id
                local charName = charData[charIndex] and charData[charIndex].name
                if charName then
                    love.graphics.printf(charName, 0, 146, w, "center")
                end
            elseif step == 2 then
                love.graphics.printf(curRarity, 0, 146, w, "center")
            end
        end
    else
        local depth = getDepth(screen)
        love.graphics.draw(bg, 0, 0)
        love.graphics.draw(last10, 0 - depth *2, 0, 0, 2, 2)

        local cols, spacing, scale = 5, 72, 2
        local gridWidth = cols * spacing
        local rows = math.ceil(#lastChars / cols)
        local gridHeight = rows * spacing
        local offsetX = (w - gridWidth) / 2
        local offsetY = (h - gridHeight) / 2

        for i = #lastChars, 1, -1 do
            local char = lastChars[i]
            local quad = chars[char]
            if quad then
                local reverseIndex = #lastChars - i
                local col = reverseIndex % cols
                local row = math.floor(reverseIndex / cols)
                local x = col * spacing + offsetX
                local y = row * spacing + offsetY
                love.graphics.draw(charSheet, quad, x - depth * 3, y, 0, scale, scale)
            end
        end
    end
end

function love.quit()
    local function indexer(key)
        if tonumber(key) then return "" else return "['" .. key .. "'] = " end
    end

    local function tableToString(tbl, indent)
        indent = indent or ""
        local str = "{"
        for k, v in pairs(tbl) do
            local keyStr = indexer(k)
            if type(v) == "table" then
                str = str .. "\n" .. indent .. keyStr .. tableToString(v, indent .. "  ") .. ","
            elseif type(v) == "string" then
                str = str .. "\n" .. indent .. keyStr .. "\"" .. v .. "\","
            else
                str = str .. "\n" .. indent .. keyStr .. tostring(v) .. ","
            end
        end
        str = str .. "\n" .. indent .. "}"
        return str
    end

    local saveData = {
        lastChars = lastChars,
        unlockedChars = unlockedChars
    }

    love.filesystem.write("save.lua", "return " .. tableToString(saveData, "  "))
end