local result = {}

local imageCache = {}
local audioCache = {}
local cache = {}

function _loadImage(path)
    if imageCache[path] ~= nil then
        return imageCache.path
    end
    imageCache[path] = love.graphics.newImage(path)
    return imageCache[path]
end
function _loadAudio(path)
    if audioCache[path] ~= nil then
        return imageCache.path
    end
    audioCache[path] = love.audio.newSource(path, 'stream')
    return audioCache[path]
end

function _loadAssetSpec(basePath)
    local fileName = basePath..'/'..'assetspec.lua'
    local spec = dofile(fileName)
    return spec
end

function result.loadAssetGroup(basePath, groupName)
    if not basePath or not groupName or type(basePath) ~= 'string' or type(groupName) ~= 'string' then
        return nil
    end
    local groupPath = basePath..'/'..groupName
    if cache[groupPath] then
        return cache[groupPath]
    end
    local spec = _loadAssetSpec(basePath)
    local ret = {}
    for i,v in ipairs(spec) do
        local fullPath = groupPath..'/'..v.path
        if v.type == 'image' then
            local fileData, err = love.filesystem.newFileData(fullPath)
            local img = nil
            if not err then
                img = _loadImage(fullPath)
            end
            if img then
                local ix, iy = img:getDimensions()
                if v.spec.width == ix and v.spec.height == iy then
                    local newItem = { image = img, quads = {} }
                    for ii, vv in ipairs(v.spec.quads) do
                        table.insert(newItem.quads, {
                            rect = love.graphics.newQuad(vv.x, vv.y, vv.w, vv.h, ix, iy),
                            ox = vv.ox or 0,
                            oy = vv.oy or 0
                        })
                    end
                    ret[i] = newItem
                end
            else
                if v.nullable then
                    ret[i] = nil
                else
                    local canvas = love.graphics.newCanvas(v.spec.width, v.spec.height)
                    love.graphics.setCanvas(canvas)
                    for ii, vv in ipairs(v.spec.quads) do
                        love.graphics.setLineWidth(2)
                        love.graphics.setColor(0.5, 0.5, 0.5, 1.0)
                        love.graphics.rectangle('line', vv.x, vv.y, vv.w, vv.h)
                        love.graphics.print(tostring(ii)..'('..tostring(vv.x)..','..tostring(vv.y)..','..tostring(vv.w)..','..tostring(vv.h)..')', vv.x + 5, vv.y + 5)
                        love.graphics.setColor(0.8, 0.8, 0.8, 1.0)
                        love.graphics.setPointSize(2)
                        love.graphics.points((vv.ox or 0) + vv.x, (vv.oy or 0) + vv.y)
                        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
                    end
                    love.graphics.setCanvas()
                    local newItem = { image = canvas, quads = {} }
                    for ii, vv in ipairs(v.spec.quads) do
                        table.insert(newItem.quads, {
                            rect = love.graphics.newQuad(vv.x, vv.y, vv.w, vv.h, v.spec.width, v.spec.height),
                            ox = vv.ox or 0,
                            oy = vv.oy or 0
                        })
                    end
                    ret[i] = newItem
                end
            end
        elseif v.type == 'audio' then
            local aud = nil
            local fileData, err = love.filesystem.newFileData(fullPath)
            local aud = nil
            if not err then
                aud = _loadAudio(fullPath)
            end
            local newItem = nil
            if aud then
                newItem = { audio = aud }
            end
            ret[i] = newItem
        end
    end
    cache[groupPath] = ret
    return ret
end

function result.checkAssetGroup(basePath)
    if not basePath or type(basePath) ~= 'string' then
        return nil
    end
    local ret = {}
    local spec = _loadAssetSpec(basePath)
    local files = love.filesystem.getDirectoryItems(basePath)
    for i,v in ipairs(files) do
        if v == 'assetspec.lua' then
            table.remove(files, i)
        end
    end
    for i,v in ipairs(files) do
        local groupPath = basePath..'/'..v
        for ii,vv in ipairs(spec) do
            local fullPath = groupPath..'/'..vv.path
            local fileData, err = love.filesystem.newFileData(fullPath)
            if err then
                if not vv.nullable then
                    table.insert(ret, {group = v, item = vv})
                end
            end
        end
    end
    return ret
end

function result.clearCache()
    for _, v in pairs(imageCache) do
        v:release()
    end
    for _, v in pairs(audioCache) do
        v:release()
    end
    imageCache = {}
    cache = {}
end

return result