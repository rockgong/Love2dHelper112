local result = {}

local logicSizeX, logicSizeY = 1280, 720

function _drawTileMapLayer(tilemapLayer, tilesetLayer, offsetX, offsetY, tileIndexMapFunc)
    local offsetTransXFactor = tilemapLayer.transFactorX or 1
    local offsetTransYFactor = tilemapLayer.transFactorY or 1
    local offsetTransXBias = tilemapLayer.transBiasX or 0
    local offsetTransYBias = tilemapLayer.transBiasY or 0
    offsetX = offsetX * offsetTransXFactor + offsetTransXBias
    offsetY = offsetY * offsetTransYFactor + offsetTransYBias
    offsetX = math.floor(offsetX)
    offsetY = math.floor(offsetY)

    local indexOffsetX = math.floor(offsetX / tilesetLayer.width)
    local indexOffsetY = math.floor(offsetY / tilesetLayer.height)
    local x, y = indexOffsetX, indexOffsetY
    local posX = - offsetX + indexOffsetX * tilesetLayer.width
    local posY = - offsetY + indexOffsetY * tilesetLayer.height
    local img = tilesetLayer.image
    while true do
        x = indexOffsetX
        posX = - offsetX + indexOffsetX * tilesetLayer.width
        while true do
            local tileIndex = -1
            local tiX = x
            local tiY = y
            if tilemapLayer.repeatX then
                tiX = x % tilemapLayer.width
            end
            if tilemapLayer.repeatY then
                tiY = y % tilemapLayer.height
            end
            if tiX < 0 or tiX >= tilemapLayer.width or tiY < 0 or tiY >= tilemapLayer.height then
                tileIndex = -1
            else
                tileIndex = tilemapLayer.map[tiY * tilemapLayer.width + tiX + 1] or -1
            end
            if tileIndex >= 0 then
                if tileIndexMapFunc then
                    tileIndex = tileIndexMapFunc(tileIndex, x, y)
                end
                if tileIndex < tilesetLayer.cntX * tilesetLayer.cntY then
                    local icX = tileIndex % tilesetLayer.cntX
                    local icY = (tileIndex - icX) / tilesetLayer.cntY
                    local quad = love.graphics.newQuad(icX * tilesetLayer.width, icY * tilesetLayer.height, tilesetLayer.width, tilesetLayer.height, img:getDimensions())
                    love.graphics.draw(img, quad, posX, posY)
                end
            end
            x = x + 1
            posX = posX + tilesetLayer.width
            if posX > logicSizeX then
                break
            end
        end
        y = y + 1
        posY = posY + tilesetLayer.height
        if posY > logicSizeY then
            break
        end
    end
end

function result.init(lsx, lsy)
    logicSizeX, logicSizeY = lsx, lsy
end

function result.drawTileMap(tilemap, tileset, offsetX, offsetY, tileIndexMapFunc)
    for i, v in ipairs(tilemap.layers) do
        local layerIndex = v.layerIndex
        local layer = tileset.layers[layerIndex]
        if layer then
            _drawTileMapLayer(v, layer, offsetX, offsetY, tileIndexMapFunc)
        end
    end
end

return result