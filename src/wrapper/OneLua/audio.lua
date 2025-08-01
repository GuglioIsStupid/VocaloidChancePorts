local channels = {} -- The psp has 2 audio channels

local extension = ".mp3"

local function newSourceObject(sourcePath, type)
    if sourcePath:match("%.ogg$") or sourcePath:match("%.wav$") then
        sourcePath = sourcePath:gsub("%..+$", extension)
    end
    local source = {}
    source.sound = sound.load(wrapper.location .. sourcePath)
    source.type = type or "static"
    function source:play()
        if self.sound then
            if self.type == "static" then
                channels[1] = self
                sound.play(self.sound, 1)
            else
                channels[2] = self
                sound.play(self.sound, 2)
            end
        end
    end
    function source:isPlaying()
        if self.sound then
            return sound.playing(self.sound)
        end
        return false
    end

    return source
end

function love.audio.newSource(source, type)
    return newSourceObject(source, type)
end
