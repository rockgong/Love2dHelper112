local result = {}

local s = require('sokoban')
local player = 0
local wall = 0

local timer = 0
local wallStep = 0
local box = 0

function result.load()
    player = s.createBlock(40, 1, 12, 22, 1)
    wall = s.createBlock(20, 25, 10, 20, 0)
    s.createBlock(40, 20, 20, 15, 0)
    s.createBlock(60, 30, 12, 1, 1)
    box = s.createBlock(85, 20, 15, 30, 1)
end

function result.update(dt)
    timer = timer + dt
    if timer > 1 then
        timer = timer - 1
        
        if s.withBlock(wall) then
            if wallStep == 0 then
                if s.moveBlock(1) then
                    wallStep = 1
                end
            elseif wallStep == 1 then
                if s.moveBlock(1) then
                    wallStep = 2
                end
            elseif wallStep == 2 then
                if s.moveBlock(3) then
                    wallStep = 3
                end
            elseif  wallStep == 3 then
                if s.moveBlock(3) then
                    wallStep = 0
                end
            end
        end
    end
end

function result.draw()
    s.foreachBlock(function(id)
        if s.withBlock(id) then
            local x, y, w, h, t = s.getBlockX(), s.getBlockY(), s.getBlockW(), s.getBlockH(), s.getBlockType()
            if id == player then
                love.graphics.setColor(1, 0, 0, 1)
            elseif t == 0 then
                love.graphics.setColor(0, 1, 0, 1)
            elseif t == 1 then
                love.graphics.setColor(0.7, 0.7, 0, 1)
            end
            love.graphics.rectangle('line', x * 10, 720 - (y + h) * 10, 10 * w, 10 * h)
            -- love.graphics.print(tostring(x).." "..tostring(y), x * 10 + 1, 720 - (y + h) * 10 + 20)
        end
    end)
end

function result.keypressed(k)
    s.withBlock(player)
    local dir = -1
    if k == 'a' then
        dir = 0
    elseif k == 'w' then
        dir = 1
    elseif k == 'd' then
        dir = 2
    elseif k == 's' then
        dir = 3
    end
    if dir == 3 then
        s.setBlockPushMode(2)
    else
        s.setBlockPushMode(0)
    end
    if dir > -1 then
        local res, contactList = s.moveBlock(dir)
        print('res = '..tostring(res))
        if contactList == nil then
            print('contactList = nil')
        else
            for i, v in ipairs(contactList) do
                print(i, v)
            end
        end
    end
    if k == 'space' then
        s.setBlockPushMode(0)
        s.moveBlock(3)
        s.setBlockPushMode(2)
    end
    if k == 'q' then
        s.cleanup()
    end
end

return result