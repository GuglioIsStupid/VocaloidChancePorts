-- A love2d wrapper for OneLua
-- Based off of https://github.com/LukeZGD/LOVE-WrapLua
wrapper = {}
wrapper.run = true
wrapper.version = "OneLua"
wrapper.location = ""
wrapper.saveLocation = ""
wrapper.timer = timer.new()
wrapper.timer:start()
wrapper.fps = 0
wrapper.currentFont = {
    _font = font.load("oneFont.pgf"),
    _size = 8,
}
font.setdefault(wrapper.currentFont._font)

love = {
    graphics = {},
    system = {},
    filesystem = {},
    audio = {},
    event = {},
    math = {},
    timer = {},
    __confdata = {identity = ""},
    __identity = ""
}

if files.exists(wrapper.location .. "conf.lua") then
    dofile(wrapper.location .. "conf.lua")
    love.conf(love.__confdata)
    love.__identity = love.__confdata.identity
end

dofile(wrapper.location .. "wrapper/OneLua/graphics.lua")
dofile(wrapper.location .. "wrapper/OneLua/audio.lua")
dofile(wrapper.location .. "wrapper/OneLua/event.lua")
dofile(wrapper.location .. "wrapper/filesystem.lua")
dofile(wrapper.location .. "wrapper/math.lua")
dofile(wrapper.location .. "wrapper/system.lua")
dofile(wrapper.location .. "wrapper/timer.lua")

love.math.setRandomSeed(os.time())

dofile(wrapper.location .. "main.lua")
dofile(wrapper.location .. "wrapper/OneLua/whileloop.lua")

love.load()

while wrapper.run do
    local dt = 0
    if wrapper.timer:time() >= 16 then
        dt = wrapper.timer:time() / 1000
        wrapper.timer:reset()
        wrapper.timer:start()
        love.update(dt)
        love.draw()
    end

    local fps = 1 / dt
    wrapper.fps = fps
end
