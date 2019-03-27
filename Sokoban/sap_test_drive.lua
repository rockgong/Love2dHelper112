local result = {}

local s = require('sap')

local timer = 0.0
local player = 0
local wall = 0
local wal2 = 0
local wal3 = 0
local box = 0

local ssxTarget = 0
local speed = 128

local wall2thread;

function result.load()
    s.init(128, 4)
    player = s.createEntity(40, 25, 12, 22, 1)
    wall = s.createEntity(0, 5, 1280, 20, 0)
    wall3 = s.createEntity(100, 25, 40, 60, 0)
    s.createEntity(30, 130, 200, 1, 1)
    wall2 = s.createEntity(200, 50, 200, 5, 0)
    box = s.createEntity(150, 160, 200, 1, 1)
end

function _wall2coroutnie()
    while true do
        local cnt = 0
        if s.withEntity(wall2) then
            s.setEntitySpeedY(50)
        end
        while true do
            cnt = cnt + 1
            coroutine.yield()
            if cnt > 150 then
                break
            end
        end
        cnt = 0
        if s.withEntity(wall2) then
            s.setEntitySpeedY(-50)
        end
        while true do
            cnt = cnt + 1
            coroutine.yield()
            if cnt > 150 then
                break
            end
        end
    end
end

function _wall3coroutine()
    while true do
        local cnt = 0
        if s.withEntity(wall3) then
            s.setEntitySpeedX(50)
        end
        while true do
            cnt = cnt + 1
            coroutine.yield()
            if cnt > 150 then
                break
            end
        end
        cnt = 0
        if s.withEntity(wall3) then
            s.setEntitySpeedX(-50)
        end
        while true do
            cnt = cnt + 1
            coroutine.yield()
            if cnt > 150 then
                break
            end
        end
    end
end

wall2thread = coroutine.create(_wall2coroutnie)
wall3thread = coroutine.create(_wall3coroutine)

function result.update(dt)
    timer = timer + dt
    while timer > 0 do
        timer = timer - 1.0 / 60
        coroutine.resume(wall2thread)
        coroutine.resume(wall3thread)
        s.process(function(id)
            print(id)
        end)
        if s.withEntity(player) then
            local ssy = s.getEntitySpeedY() or 0
            ssy = ssy - 15
            if ssy < -500 then
                ssy = -500
            end
            if ssy < 0 then
                s.setEntityPushMode(2)
            else
                s.setEntityPushMode(0)
            end
            s.setEntitySpeedY(ssy)
            local ssx = s.getEntitySpeedX() or 0
            local ssxLeft = ssx - 15
            local ssxRight = ssx + 15
            ssx = ssxTarget
            ssx = math.max(ssxLeft, ssx)
            ssx = math.min(ssxRight, ssx)
            s.setEntitySpeedX(ssx)
        end
    end
end

function result.draw()
    s.foreachEntity(function(id)
        if s.withEntity(id) then
            local x, y, w, h, t = s.getEntityX(), s.getEntityY(), s.getEntityW(), s.getEntityH(), s.getEntityType()
            if id == player then
                love.graphics.setColor(1, 0, 0, 1)
            elseif t == 0 then
                love.graphics.setColor(0, 1, 0, 1)
            elseif t == 1 then
                love.graphics.setColor(0.7, 0.7, 0, 1)
            end
            love.graphics.rectangle('line', x * 1, 720 - (y + h) * 1, 1 * w, 1 * h)
            -- love.graphics.print(tostring(x).." "..tostring(y), x * 10 + 1, 720 - (y + h) * 10 + 20)
        end
    end)
end

function result.keypressed(k)
    if s.withEntity(player) then
        if k == 'a' then
            ssxTarget = ssxTarget - 400
        end
        if k == 'd' then
            ssxTarget = ssxTarget + 400
        end
        if k == 'space' then
            if s.getEntityGrounded() then
                s.setEntitySpeedY(500)
            end
        end
    end
end
function result.keyreleased(k)
    if s.withEntity(player) then
        if k == 'a' then
            ssxTarget = ssxTarget + 400
        end
        if k == 'd' then
            ssxTarget = ssxTarget - 400
        end
    end
end

return result