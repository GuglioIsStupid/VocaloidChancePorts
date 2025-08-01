function love.math.setRandomSeed(seed)
    return math.randomseed(seed)
end

function love.math.random(a,b)
    if b == nil then
        return math.random(1, a)
    else
        return math.random(a, b)
    end
end
