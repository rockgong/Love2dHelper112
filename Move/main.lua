local fg = require('functional_graphic')

local timer = 0
local mx, my = 0
local sw, sh = love.graphics.getDimensions()

local drawFunc = function(t)
    love.graphics.circle('fill', 0, 0, t, 60)
end
local easeFunc = fg.easeInAndOut(2)
drawFunc = fg.combine(function(t) return t * 200 end, drawFunc)
drawFunc = fg.combine(easeFunc, drawFunc)
drawFunc = fg.combine(function() return mx / sw end, drawFunc)
drawFunc = fg.trans(drawFunc, 200, 200)

function love.update(dt)
    timer = timer + dt
end

function love.draw()
    drawFunc()
end

function love.mousemoved(x, y)
    mx, my = x, y
end