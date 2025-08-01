---@diagnostic disable: undefined-global

local o_lovedraw = love.draw
local o_loveupdate = love.update
function love.draw()
    o_lovedraw()

    screen.flip()
end

local allowed = {
    "up", "down", "left", "right",
    "circle", "cross", "triangle", "square",
    "l", "r",
    "start", "select", "home",
    "volup", "voldown"
}
local convertToGamepad = {
    up = "dpleft",
    down = "dpright",
    left = "dpup",
    right = "dpdown",
    circle = "b",
    cross = "a",
    triangle = "y",
    square = "x",
    l = "leftshoulder",
    r = "rightshoulder",
    start = "start",
    select = "back",
    home = "guide"
}
local convertToAllowed = {
    dpleft = "up",
    dpright = "down",
    dpup = "left",
    dpdown = "right",
    a = "circle",
    b = "cross",
    y = "triangle",
    x = "square",
    leftshoulder = "l",
    rightshoulder = "r",
    start = "start",
    back = "select",
    guide = "home"
}

local joystick = {} -- emulated joystick
function joystick:isGamepadDown(button)
    return buttons[convertToAllowed[button]] or false
end

function love.update(dt)
    o_loveupdate(dt)

    buttons.read()
    for _, button in ipairs(allowed) do
        if buttons[button] then
            if love.gamepadpressed then
                love.gamepadpressed(joystick, convertToGamepad[button])
            end
        end
    end
end
