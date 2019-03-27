local skb = require('sokoban')
local result = {}

local speedDivision = 1
local iterNum = 1
local entities = {}
local thisEntity = nil

function _foreachEntity(func)
    for i, v in ipairs(entities) do
        if func(i, v) then
            break
        end
    end
end

function result.init(sd, itn)
    speedDivision = sd or 1
    iterNum = itn or 1
    skb.setPushMode(0)
end

function result.createEntity(x, y, w, h, type, sx, sy)
    local id = 0
    w = w or 1
    h = h or 1
    type = type or 1
    _foreachEntity(function(i, b)
        if b.idle then
            id = i
            b.idle = false
            return true
        end
        return false
    end)
    if id > 0 then
        return id
    end
    local newEntity = 
    {
        blockId = skb.createBlock(x, y, w, h, type),
        sx = sx,
        sy = sy
    }
    table.insert(entities, newEntity)
    return #entities
end

function result.hasEntity(id)
    return entities[id] and not entities[id].idle
end

function result.removeEneity(id)
    if not result.hasEntity(id) then
        return false
    end
    skb.removeBlock(entities[id].blockId)
    entities[id].idle = true
end

function result.cleanup()
    skb.cleanup()
    entities = {}
end

function result.foreachEntity(func)
    for i, v in ipairs(entities) do
        if not v.idle then
            func(i)
        end
    end
end

function result.process(func)
    local stepCost = speedDivision * iterNum
    for i = 1,iterNum do
        _foreachEntity(function(i, entity)
            if entity.idle then
                return false
            end
            local eix = entity.ix or 0
            local eiy = entity.iy or 0
            local dix = entity.sx or 0
            local diy = entity.sy or 0
            eix = eix + dix
            eiy = eiy + diy
            while eix >= stepCost or eix < 0 do
                local dir = -1
                if eix < 0 then
                    eix = eix + stepCost
                    dir = 0
                elseif eix >= stepCost then
                    eix = eix - stepCost
                    dir = 2
                end
                if skb.withBlock(entity.blockId) then
                    local res, cl = skb.moveBlock(dir)
                    if not res then
                        entity.sx = 0
                    end
                    if cl then
                        if func and type(func) == 'function' then
                            for i,v in ipairs(cl) do
                                for ii, vv in ipairs(entities) do
                                    if vv.blockId == v then
                                        func(ii)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            while eiy >= stepCost or eiy < 0 do
                local dir = -1
                if eiy < 0 then
                    eiy = eiy + stepCost
                    dir = 3
                elseif eiy >= stepCost then
                    eiy = eiy - stepCost
                    dir = 1
                end
                if skb.withBlock(entity.blockId) then
                    local res = skb.moveBlock(dir)
                    if not res then
                        entity.sy = 0
                    end
                end
            end
            if skb.withBlock(entity.blockId) then
                local checkground = skb.moveBlock(3)
                if not checkground then
                    entity.grounded = true
                    entity.sy = 0
                else
                    entity.grounded = false
                    skb.moveBlock(1)
                end
            end
            entity.ix = eix
            entity.iy = eiy
        end)
    end
end

function result.withEntity(id)
    if not id then
        thisEntity = nil
        return false
    end
    if result.hasEntity(id) then
        thisEntity = entities[id]
        return true
    end
    return false
end

-- block property query
function result.getEntityX()
    if thisEntity then
        if skb.withBlock(thisEntity.blockId) then
            return skb.getBlockX()
        end
    end
    return nil
end

function result.getEntityY()
    if thisEntity then
        if skb.withBlock(thisEntity.blockId) then
            return skb.getBlockY()
        end
    end
    return nil
end

function result.getEntityW()
    if thisEntity then
        if skb.withBlock(thisEntity.blockId) then
            return skb.getBlockW()
        end
    end
    return nil
end

function result.getEntityH()
    if thisEntity then
        if skb.withBlock(thisEntity.blockId) then
            return skb.getBlockH()
        end
    end
    return nil
end

function result.getEntityType()
    if thisEntity then
        if skb.withBlock(thisEntity.blockId) then
            return skb.getBlockType()
        end
    end
    return nil
end

function result.getEntitySpeedX()
    if thisEntity then
        return thisEntity.sx
    end
    return nil
end

function result.getEntityGrounded()
    if thisEntity then
        return thisEntity.grounded or false
    end
    return false
end

function result.getEntitySpeedY()
    if thisEntity then
        return thisEntity.sy
    end
    return nil
end

-- block operation
function result.setEntityX(val)
    if thisEntity then
        if skb.withBlock(thisEntity.blockId) then
            skb.setBlockX(val)
        end
    end
end

function result.setEntityY(val)
    if thisEntity then
        if skb.withBlock(thisEntity.blockId) then
            skb.setBlockY(val)
        end
    end
end

function result.setEntityW(val)
    if thisEntity then
        if skb.withBlock(thisEntity.blockId) then
            skb.setBlockW(val)
        end
    end
end

function result.setEntityH(val)
    if thisEntity then
        if skb.withBlock(thisEntity.blockId) then
            skb.setBlockH(val)
        end
    end
end

function result.setEntityPushMode(val)
    if thisEntity then
        if skb.withBlock(thisEntity.blockId) then
            skb.setBlockPushMode(val)
        end
    end
end

function result.setEntitySpeedX(val)
    if thisEntity then
        thisEntity.sx = val
    end
end

function result.setEntitySpeedY(val)
    if thisEntity then
        thisEntity.sy = val
    end
end


return result