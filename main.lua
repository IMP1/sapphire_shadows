local tlo        = require 'lib_tlo'
T = tlo.localise

local SceneManager = require 'scn_scn_manager'

DEBUG = {
    drawables = {},
    messages  = {},
}

function love.load()
    SceneManager.setScene(require('scn_game').new())
end

function love.update(dt)
    SceneManager.update(dt)
end

function love.mousepressed(mx, my, key)
    SceneManager.mousepressed(mx, my, key)
end

function love.keypressed(key)
    SceneManager.keypressed(key)
end

function love.draw()
    SceneManager.draw()
    for _, d in pairs(DEBUG.drawables) do
        love.graphics.setColor(255, 255, 255)
        d()
    end
end