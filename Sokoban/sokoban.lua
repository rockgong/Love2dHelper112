local result = {}

local blocks = {}
local thisBlock = nil
local pushMode = 1

function _foreachBlock(func)
    for i, v in ipairs(blocks) do
        if func(i, v) then
            break
        end
    end
end

function _moveBlock(block, dir, positive, justDetect)
    local contactList = nil
    if block then
        local _contactList = function() if not contactList then contactList = {} end return contactList end
        local actualPushMode = block.pushMode or pushMode
        local targetX = block.x
        local targetY = block.y
        local horv = false
        local linePos = 0
        local rangePos0 = 0
        local rangePos1 = 0
        if dir == 0 then
            targetX = targetX - 1
            horv = true
            linePos = targetX
            rangePos0 = block.y
            rangePos1 = block.y + block.h
        elseif dir == 1 then
            targetY = targetY + 1
            horv = false
            linePos = targetY + block.h - 1
            rangePos0 = block.x
            rangePos1 = block.x + block.w
        elseif dir == 2 then
            targetX = targetX + 1
            horv = true
            linePos = targetX + block.w - 1
            rangePos0 = block.y
            rangePos1 = block.y + block.h
        elseif dir == 3 then
            targetY = targetY - 1
            horv = false
            linePos = targetY
            rangePos0 = block.x
            rangePos1 = block.x + block.w
        end
        if targetX ~= block.x or targetY ~= block.y then
            local canMove = true
            local pushId = {}
            for i, v in ipairs(blocks) do
                if v ~= block then
                    local intersect = false
                    if horv then
                        intersect = v.x <= linePos and
                                v.x + v.w > linePos and
                                v.y < rangePos1 and
                                v.y + v.h > rangePos0 
                    else
                        intersect = v.y <= linePos and
                                v.y + v.h > linePos and
                                v.x < rangePos1 and
                                v.x + v.w > rangePos0 
                    end
                    if intersect then
                        canMove = canMove and v.type > 0
                        table.insert(_contactList(), i)
                        if canMove then
                            table.insert(pushId, i)
                        else
                            break
                        end
                    end
                end
            end
            if canMove then
                if block.type == 0 then
                    for i, v in ipairs(pushId) do
                        canMove = canMove and _moveBlock(blocks[v], dir, false, true)
                        if not canMove then
                            break
                        end
                    end
                    if canMove and not justDetected then
                        for i, v in ipairs(pushId) do
                            _moveBlock(blocks[v], dir, false, false)
                        end
                    end
                else
                    if actualPushMode == 0 then
                        canMove = true
                    elseif actualPushMode == 1 then
                        for i, v in ipairs(pushId) do
                            canMove = canMove and _moveBlock(blocks[v], dir, false, true)
                            if not canMove then
                                break
                            end
                        end
                        if canMove and not justDetected then
                            for i, v in ipairs(pushId) do
                                _moveBlock(blocks[v], dir, false, false)
                            end
                        end
                    elseif actualPushMode == 2 then
                        canMove = #pushId == 0
                    end
                end
                if canMove then
                    if not justDetect then
                        block.x = targetX
                        block.y = targetY
                    end
                    return true, contactList
                end
            end
        end
    end
    return false, contactList
end

-- state setting
function result.setPushMode(mode)
    pushMode = mode
end

-- block management
function result.createBlock(x, y, w, h, type)
    local id = 0
    w = w or 1
    h = h or 1
    type = type or 1
    _foreachBlock(function(i, b)
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
    local newBlock = 
    {
        x = x,
        y = y,
        w = w,
        h = h,
        type = type
    }
    table.insert(blocks, newBlock)
    return #blocks
end

function result.hasBlock(id)
    return blocks[id] and not blocks[id].idle
end

function result.removeBlock(id)
    if not result.hasBlock(id) then
        return false
    end
    blocks[id].idle = true
end

function result.cleanup()
    blocks = {}
end

function result.foreachBlock(func)
    for i, v in ipairs(blocks) do
        if not v.idle then
            func(i)
        end
    end
end

function result.withBlock(id)
    if not id then
        thisBlock = nil
        return false
    end
    if result.hasBlock(id) then
        thisBlock = blocks[id]
        return true
    end
    return false
end

-- block property query
function result.getBlockX()
    if thisBlock then
        return thisBlock.x
    end
    return nil
end

function result.getBlockY()
    if thisBlock then
        return thisBlock.y
    end
    return nil
end

function result.getBlockW()
    if thisBlock then
        return thisBlock.w
    end
    return nil
end

function result.getBlockH()
    if thisBlock then
        return thisBlock.h
    end
    return nil
end

function result.getBlockType()
    if thisBlock then
        return thisBlock.type
    end
    return nil
end


-- block operation
function result.setBlockX(val)
    if thisBlock then
        thisBlock.x = val
    end
end

function result.setBlockY(val)
    if thisBlock then
        thisBlock.y = val
    end
end

function result.setBlockW(val)
    if thisBlock then
        thisBlock.w = val
    end
end

function result.setBlockH(val)
    if thisBlock then
        thisBlock.h = val
    end
end

function result.setBlockPushMode(val)
    if thisBlock then
        thisBlock.pushMode = val
    end
end

-- move function
function result.moveBlock(dir)
    return _moveBlock(thisBlock, dir, true, false)
end

return result