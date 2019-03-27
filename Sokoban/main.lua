-- local drive = require('sokoban_test_drive')
local drive = require('sap_test_drive')

function love.load()
    if drive.load then drive.load() end
end

function love.update(dt)
    if drive.update then drive.update(dt) end
end

function love.draw()
    if drive.draw then drive.draw() end
end

function love.keypressed(k)
    if drive.keypressed then drive.keypressed(k) end
end

function love.keyreleased(k)
    if drive.keyreleased then drive.keyreleased(k) end
end