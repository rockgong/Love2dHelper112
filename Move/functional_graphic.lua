local result = {}

-- functional
function _eval(obj, defVal)
    if obj == nil then
        return defVal or 0
    end
    if type(obj) == 'function' then
        obj = obj()
    end
    return obj or 0
end

function result.eval(obj, defVal)
    return _eval(obj, defVal)
end

function result.combine(func0, func1)
    return function(...)
        return func1(func0(...))
    end
end

-- love graphics
function result.trans(func, tx, ty, r, sx, sy)
    sx = sx or 1
    sy = sy or sx
    r = r or 0
    tx = tx or 0
    ty = ty or 0
    return function(...)
        love.graphics.push()
        love.graphics.translate(_eval(tx), _eval(ty))
        love.graphics.rotate(_eval(r))
        love.graphics.scale(_eval(sx), _eval(sy))
        func(...)
        love.graphics.pop()
    end
end

function result.color(func, r, g, b, a)
    r = r or 1
    g = g or 1
    b = b or 1
    a = a or 1
    return function(...)
        local r0, g0, b0, a0 = love.graphics.getColor()
        love.graphics.setColor(_eval(r), _eval(g), _eval(b), _eval(a))
        func(...)
        love.graphics.setColor(_eval(r0), _eval(g0), _eval(b0), _eval(a0))
    end
end

function result.shader(func, shaderCode, paramTable)
    if shaderCode == nil or type(shaderCode) ~= 'string' then
        return func
    end
    local shader = love.graphics.newShader(shaderCode)
    return function(...)
        love.graphics.setShader(shader)
        if paramTable and type(paramTable) == 'table' then
            for k, v in pairs(paramTable) do
                if shader:hasUniform(k) then
                    shader:send(k, _eval(v))
                end
            end
        end
        func(...)
        love.graphics.setShader()
    end
end

function result.stencil(func0, func1)
    return function(...)
        love.graphics.stencil(func0, 'replace', 1)
        love.graphics.setStencilTest('greater', 0)
        func1(...)
        love.graphics.setStencilTest()
    end
end

--(0 to 1) to (0 to 1) map math
function result.easeIn(iterTime)
    return function(t)
        for i = 1,iterTime do
            t = t * math.pi / 2
            t = math.sin(t)
        end
        return t
    end
end

function result.easeOut(iterTime)
    return function(t)
        for i = 1,iterTime do
            t = (t - 1) * math.pi / 2
            t = math.sin(t) + 1
        end
        return t
    end
end

function result.easeInAndOut(iterTime)
    return function(t)
        for i = 1,iterTime do
            t = (t - 0.5) * math.pi
            t = math.sin(t) * 0.5 + 0.5
        end
        return t
    end
end

function result.linearTrans(func, ax, bx, ay, by)
    return function(t)
        t = ax * t + bx
        t = func(t)
        t = ay * t + by
        return t
    end
end

function result.clamp01(func)
    return function(t)
        if t < 0 then t = 0 end
        if t > 1 then t = 1 end
        return func(t)
    end
end

function result.mirror01(func)
    return function(t)
        local m = math.floor(t) % 2
        if m == 0 then
            t = t - math.floor(t)
        elseif m == 1 then
            t = math.floor(t + 1) - t
        end
        return func(1)
    end
end

function result.repeat01(func)
    return function(t)
        return func(t - math.floor(t))
    end
end

return result