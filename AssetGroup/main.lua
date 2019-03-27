local ag = require('assetgroup')

local spec = ag.loadAssetGroup('asset', 'group1')
local lack = ag.checkAssetGroup('asset')

for i,v in ipairs(lack) do
    print('lack : ', v.group, v.item.path)
end

local listItems = {}
function dump(obj, layer)
    layer = layer or 0
    local padding = string.rep('  ', layer)
    local innerPadding = string.rep('  ', layer + 1)
    --print(padding..'{')
    --table.insert(listItems, {padding..'{', nil})
    for k, v in pairs(obj) do
        if type(v) == 'table' then
            --print(innerPadding..tostring(k)..':')
            table.insert(listItems, {innerPadding..tostring(k)..':', v})
            dump(v, layer + 1)
        else
            --print(innerPadding..tostring(k)..":"..tostring(v))
            --table.insert(listItems, {innerPadding..tostring(k)..":"..tostring(v), nil})
        end
    end
    --print(padding..'}')
    --table.insert(listItems, {padding..'}', nil})
end

local currentListItem = 1
local currentSpecItem = nil
local playerAudio = nil
dump(spec)

function drawQuad(image, quad, x, y, r, sx, sy)
    if not image then
        return
    end
    love.graphics.draw(image, quad.rect, x, y, r, sx, sy, quad.ox, quad.oy)
end

local timer = 0

function love.update(dt)
    timer = timer + dt
end

function _drawList()
    if spec then
        local ypos = 5
        for i,v in ipairs(listItems) do
            if i == currentListItem then
                love.graphics.setColor(0.8, 0.8, 0.0, 1.0)
            else
                love.graphics.setColor(1, 1, 1, 1.0)
            end
            love.graphics.print(v[1], 5, ypos)
            ypos = ypos + 15
        end
    end
end

function _drawImage()
    if currentSpecItem then
        if currentSpecItem['image'] then
            love.graphics.draw(currentSpecItem['image'], 0, 0)
        end
    end
end

function _drawRectBySpec(x, y, w, h)
    local image = spec[1].image
    for yy=y,y+h-1 do
        for xx=x,x+w-1 do
            print(xx, yy)
            local q = nil
            if xx == x then
                if yy == y then
                    q = spec[1].quads[1]
                elseif yy == y + h - 1 then
                    q = spec[1].quads[7]
                else
                    q = spec[1].quads[4]
                end
            elseif xx == x + w - 1 then
                if yy == y then
                    q = spec[1].quads[3]
                elseif yy == y + h - 1 then
                    q = spec[1].quads[9]
                else
                    q = spec[1].quads[6]
                end
            else
                if yy == y then
                    q = spec[1].quads[2]
                elseif yy == y + h - 1 then
                    q = spec[1].quads[8]
                else
                    q = spec[1].quads[5]
                end
            end
            drawQuad(image, q, xx * 32, yy * 32)
        end
    end
end

function love.draw()
    if spec then
        love.graphics.setLineWidth(2)
        love.graphics.push()
        love.graphics.translate(5, 5)
        love.graphics.rectangle('line', 0, 0, 305, 710)
        _drawList()
        love.graphics.pop()
        love.graphics.push()
        love.graphics.translate(315, 5)
        love.graphics.rectangle('line', 0, 0, 960, 710)
        _drawImage()
        _drawRectBySpec(17, 3, 6, 13)
        _drawRectBySpec(5, 6, 12, 3)
        love.graphics.pop()
    end
end

function love.keypressed(k)
    if k == 'space' then
        if currentSpecItem then
            print(currentSpecItem['audio'])
        end
        if currentSpecItem and currentSpecItem['audio'] then
            love.audio.stop(currentSpecItem['audio'])
            love.audio.play(currentSpecItem['audio'])
            playerAudio = currentSpecItem['audio']
        end
    end

    if k == 'up' then
        currentListItem = math.max(1, currentListItem - 1)
        currentSpecItem = listItems[currentListItem][2]
    end
    if k == 'down' then
        currentListItem = math.min(#listItems, currentListItem + 1)
        currentSpecItem = listItems[currentListItem][2]
    end

    if k == '1' then
        if playerAudio then
            love.audio.stop(playerAudio)
        end
        spec = ag.loadAssetGroup('asset', 'group0')
        listItems = {}
        dump(spec)
        currentListItem = 1
        currentSpecItem = listItems[currentListItem][2]
    end
    if k == '2' then
        if playerAudio then
            love.audio.stop(playerAudio)
        end
        spec = ag.loadAssetGroup('asset', 'group1')
        listItems = {}
        dump(spec)
        currentListItem = 1
        currentSpecItem = listItems[currentListItem][2]
    end
end