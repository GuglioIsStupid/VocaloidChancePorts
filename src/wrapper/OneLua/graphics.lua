local _fonts = {}

local WHITE = color.new(255, 255, 255, 255)

local function isNilOrEmpty(value)
    return value == nil or (type(value) == "string" and value == "") or (type(value) == "table" and next(value) == nil) or (type(value) == "number" and value == 0)
end

function love.graphics.newImage(file)
    local imgObject = {
        _texture = image.load(wrapper.location .. file),
        __lastRotation = 0
    }

    imgObject.getWidth = function(self)
        return image.getrealw(self._texture)
    end
    imgObject.getHeight = function(self)
        return image.getrealh(self._texture)
    end
    imgObject.__getWidth = function(self)
        return image.getw(self._texture)
    end
    imgObject.__getHeight = function(self)
        return image.geth(self._texture)
    end
    imgObject.__resize = function(self, w, h)
        if not isNilOrEmpty(w) and not isNilOrEmpty(h) then
            image.resize(self._texture, w, h)
        end
    end
    imgObject.__rotate = function(self, angle)
        if not isNilOrEmpty(angle) then
            image.rotate(self._texture, (angle / math.pi) * 180)
        end
    end
    imgObject.blit = function(self, x, y)
        if not isNilOrEmpty(x) and not isNilOrEmpty(y) then
            image.blit(self._texture, x, y)
        end
    end

    return imgObject
end

function love.graphics.print(text, x, y)
    local size = wrapper.currentFont._size / 18.5 -- Magic number!!!!!!
    if not x then
        x = 0
    end
    if not y then
        y = 0
    end

    if text then
        screen.print(x, y, text, size)
    end
end

local function estimateTextWidth(text, font)
    if not text or isNilOrEmpty(text) then
        return 0
    end
    return screen.textwidth(text, font._size / 18.5)
end

local function wrap_text(text, limit, font)
    if not limit or limit <= 0 then
        local lines = {}
        for line in text:gmatch("([^\n]*)\n?") do
            table.insert(lines, line)
        end
        return lines
    end

    local words = {}
    for word in text:gmatch("%S+") do
        table.insert(words, word)
    end

    local lines = {}
    local line = ""

    for _, word in ipairs(words) do
        local test = (line == "") and word or (line .. " " .. word)
        if estimateTextWidth(test, font) <= limit then
            line = test
        else
            table.insert(lines, line)
            line = word
        end
    end
    if line ~= "" then
        table.insert(lines, line)
    end

    return lines
end

function love.graphics.printf(text, x, y, limit, align)
    local size = wrapper.currentFont._size / 18.5
    if not x then x = 0 end
    if not y then y = 0 end
    if not text then return end

    local lines = wrap_text(text, limit, wrapper.currentFont)
    local y_offset = 0

    for _, line in ipairs(lines) do
        local line_width = estimateTextWidth(line, wrapper.currentFont)
        local draw_x = x

        if align == "center" then
            draw_x = x + (limit - line_width) / 2
        elseif align == "right" then
            draw_x = x - line_width
        end

        screen.print(draw_x, y + y_offset, line, size, WHITE)
        y_offset = y_offset + size
    end
end

function love.graphics.setColor()
end

function love.graphics.getWidth()
    return 480
end

function love.graphics.getHeight()
    return 270
end

function love.graphics.getDimensions()
    return 480, 270
end

function love.graphics.getDepth() -- For compatibility
    return 0
end

function love.graphics.getActiveScreen() -- For compatibility
    return "default"
end

function love.graphics.setDefaultFilter(min, mag, ani)

end

function love.graphics.newFont(newFont, size)
    if tonumber(newFont) then
        size = newFont
        newFont = "assets/pixearg.ttf"
    elseif size == nil then
        size = 12
    end

    return {
        _font = font.load(wrapper.location .. newFont),
        _size = size,
    }
end

function love.graphics.setFont(font)
    wrapper.currentFont = font
end

function love.graphics.draw(texture, x, y, r, sx, sy, ox, oy)
    x = x or 0
    y = y or 0
    r = r or 0
    sx = sx or 1
    sy = sy or sx
    ox = ox or 0
    oy = oy or 0

    if sx == 0 or sy == 0 then
        return
    end

    --if r ~= texture.__lastRotation then
        image.rotate(texture._texture, (r / math.pi) * 180)
    --end

    image.resize(texture._texture, texture:getWidth() * sx, texture:getHeight() * sy)
    if ox == texture:getWidth() / 2 and oy == texture:getHeight() / 2 then
        ox = texture:__getWidth() / 2
        oy = texture:__getHeight() / 2
    end
    x = x - ox
    y = y - oy
    if r ~= 0 then
        local cos = math.cos(r)
        local sin = math.sin(r)
        x = x + ox * (1 - cos) + oy * sin
        y = y + oy * (1 - cos) - ox * sin
    end
    image.blit(texture._texture, x, y)
end
