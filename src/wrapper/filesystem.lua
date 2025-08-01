wrapper.saveLocation = "ms0:/PSP/GAME/" .. love.__identity .. "/savedata/"

if not files.exists(wrapper.saveLocation) then
    files.mkdir(wrapper.saveLocation)
end

function love.filesystem.read(file)
    local content
    if files.exists(wrapper.location .. file) then
        file = wrapper.location .. file
    elseif files.exists(wrapper.saveLocation .. file) then
        file = wrapper.saveLocation .. file
    end

    local f = io.open(file, "r")
    if f then
        content = f:read("*a")
        f:close()
    end

    return content
end

function love.filesystem.lines(file)
    local lines = {}
    for line in love.filesystem.read(file):gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    return lines
end

function love.filesystem.getInfo(file)
    local exists = false
    if files.exists(wrapper.location .. file) then
        exists = true
    end

    if files.exists(wrapper.saveLocation .. file) then
        exists = true
    end

    return exists
end

function love.filesystem.load(file)
    -- returns a function that can be called to execute the loaded file
    local content = love.filesystem.read(file)
    if not content then
        return nil, "File not found: " .. file
    end
    local func, err = loadstring(content, "@" .. file)
    if not func then
        return nil, "Error loading file: " .. err
    end
    return func
end

function love.filesystem.write(file, content)
    local f = io.open(wrapper.saveLocation .. file, "w")
    if f then
        f:write(content)
        f:close()
        return true
    end
    return false
end