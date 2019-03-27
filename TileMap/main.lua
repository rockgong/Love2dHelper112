local t = require('tilemap')

local content = {}
local tm =
{
    layers = 
    {
        {
            transFactorX = 0.1,
            transFactorY = 0.1,
            repeatX = true,
            repeatY = true,
            layerIndex = 1,
            width = 3,
            height = 3,
            map = 
            {
                0, 0, 0,
                0, 0, 0,
                0, 0, 0
            }
        },
        {
            layerIndex = 1,
            width = 4,
            height = 4,
            map = 
            {
                5, 5, 5, 5,
                0, 5, 0, 0,
                0, 5, 0, 5,
                4, 5, 5, 5,
            }
        }
    }
}

local ts =
{
    layers = 
    {
        {
            image = love.graphics.newImage('1.png'),
            width = 32,
            height = 32,
            cntX = 4,
            cntY = 4
        },
        {
            image = love.graphics.newImage('2.png'),
            width = 32,
            height = 32,
            cntX = 1,
            cntY = 1
        }
    }
}

local offsetX = 0
local offsetY = 0

local sx, sy = 0, 0
local speed = 1
local timer = 0.0

function love.load()
    t.init(1280, 720)
end

function love.update(dt)
    offsetX = offsetX + sx * speed
    offsetY = offsetY + sy * speed
    timer = timer + dt
end

function love.draw()
    local st = math.sin(timer) * 0.5 + 0.5
    love.graphics.setColor(st, st, st, 1)
    t.drawTileMap(tm, ts, offsetX, offsetY, function(i, x, y)
        if i == 0 then
            local refVal = (math.floor(timer * 15) + math.floor(x * 0.8) + math.floor(y * 0.8)) % 6
            if refVal == 0 then
                return 1
            elseif refVal == 1 then
                return 2
            elseif refVal == 2 then
                return 3
            elseif refVal == 3 then
                return 2
            elseif refVal == 4 then
                return 1
            elseif refVal == 5 then
                return 0
            end
        end
        return i
    end)
    love.graphics.setColor(1, 1, 1, 1)
    local yp = 10
    for i, v in ipairs(content) do
        love.graphics.print(v, 10, yp)
        yp = yp + 15
    end
end

function love.keypressed(k)
    if k == 'w' then
        sy = sy - 1
    end
    if k == 's' then
        sy = sy + 1
    end
    if k == 'a' then
        sx = sx - 1
    end
    if k == 'd' then
        sx = sx + 1
    end
end

function love.keyreleased(k)
    if k == 'w' then
        sy = sy + 1
    end
    if k == 's' then
        sy = sy - 1
    end
    if k == 'a' then
        sx = sx + 1
    end
    if k == 'd' then
        sx = sx - 1
    end
end