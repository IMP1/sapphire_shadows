local pathfinder = require 'lib_pathfinder'

local guard = require 'cls_guard'
local actor = require 'cls_character'

DEBUG = {
    drawables = {},
    messages  = {},
}

function love.load()
    map = {
        {32, 32, 24, 96, 128, 128, 96, 24},
        {96, 24, 128, 128, 200, 90, 192, 24},
        {192, 24, 200, 90, 244, 140, 300, 50},
        {24, 96, 32, 190, 128, 128},
        {244, 140, 270, 190, 350, 160, 300, 50},
        {244, 140, 190, 165, 210, 215, 270, 190},
        {32, 190, 60, 256, 160, 160, 128, 128},
        -- {},
    }
    pathfinder.map(map)
    guards = {
        guard.new({
            name = "foo",
            position = {80, 80},
            direction = -1,
            patrol = {
                {170, 40}, {250, 70}, {80, 80}, 
            },
        }),
    }
    party = {
        actor.new({
            name = "bar",
            position = {230, 180},
            direction = 0,
        }),
    }
    action = nil
end

function love.update(dt)
    for _, g in pairs(guards) do 
        g:update(dt, map) 
    end
    for _, g in pairs(party) do 
        g:update(dt, map) 
    end
end

function love.mousepressed(mx, my, key)
    if key == 2 then
        local path = pathfinder.path(party[1].position, {mx, my})
        if path then
            party[1].path = path
        end
    end    

    if key == 1 and action then
        if action == "noise" then
            
        elseif action == "teleport" then
            party[1].position = {mx, my}
        elseif action == "sighting" then
            
        elseif action == "distraction" then

        end
        action = nil
    end
end

function love.keypressed(key)
    if key == "escape" then
        party[1].path = nil
    end


    if key == "n" then
        action = "noise"
    end
    if key == "t" then
        action = "teleport"
    end
end

local function draw_map(map)
    for _, shape in pairs(map) do
        love.graphics.setColor(128, 255, 255, 32)
        love.graphics.polygon("fill", unpack(shape))
        love.graphics.setColor(255, 255, 255)
        love.graphics.polygon("line", unpack(shape))

        for i = 1, #shape, 2 do
            love.graphics.print(math.floor(i/2), shape[i], shape[i+1] - 8)
        end
    end
end

function love.draw()
    local mx, my = love.mouse.getPosition()

    draw_map(map)

    for _, g in pairs(guards) do 
        g:draw() 
    end
    for _, g in pairs(party) do 
        g:draw() 
    end

    if action then
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(action, 255, 0)
    end

    for _, d in pairs(DEBUG.drawables) do
        love.graphics.setColor(255, 255, 255)
        d()
    end

    love.graphics.setColor(255, 255, 255)
    love.graphics.print(mx .. ", " .. my, 0, 0)
end