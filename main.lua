local p = print
local msg = {}
print = function(...) 
    p(...)
    local arg = {...}
    local line = ""
    for _, a in ipairs(arg) do
        line = line .. a .. "\n"
    end
    table.insert(msg, line)
    DEBUG.print = function()
        love.graphics.print(msg, 460, 0)
    end
end


local pathfinder = require 'lib_pathfinder'

DEBUG = {}

function love.load()
    map = {
        {32, 32, 24, 96, 128, 128, 96, 24},
        {96, 24, 128, 128, 200, 90, 192, 24},
        {192, 24, 200, 90, 244, 140, 300, 50},
        {24, 96, 32, 190, 128, 128},
        {244, 140, 270, 190, 350, 160, 300, 50},
        {244, 140, 190, 165, 210, 215, 270, 190},
        -- {},
    }
    pathfinder.map(map)
    path_start = nil
    path_end = nil
    timer = 0
    demo_timer = 0
    demo_stage = 0
    path = nil
end

function love.update(dt)
    timer = timer + dt
end

function love.mousepressed(mx, my, key)
    if key == 1 then
        path_start = {mx, my}
    end
    if key == 2 then
        path_end = {mx, my}
    end
    path = nil
    demo_stage = 0
end

function love.keypressed(key)
    if key == "space" and path_start and path_end then
        if not path then
            path = pathfinder.path(path_start, path_end)
        else
            demo_stage = math.min(demo_stage + 1, #DEMONSTRATION)
            print(demo_stage .. "/" .. #DEMONSTRATION)
        end
    end
end

function love.draw()
    local mx, my = love.mouse.getPosition()

    for _, shape in pairs(map) do
        love.graphics.setColor(128, 255, 255, 32)
        love.graphics.polygon("fill", unpack(shape))
        love.graphics.setColor(255, 255, 255)
        love.graphics.polygon("line", unpack(shape))

        for i = 1, #shape, 2 do
            love.graphics.print(math.floor(i/2), shape[i], shape[i+1] - 8)
        end
    end

    if path_start then
        love.graphics.circle("line", path_start[1], path_start[2], (timer * 6) % 4)

        if love.keyboard.isDown("lshift") then
            love.graphics.line(path_start[1], path_start[2], mx, my)
        end
    end

    if path_end then
        love.graphics.circle("line", path_end[1], path_end[2], (6 - timer * 6) % 4)
    end

    if path then
        for i = 1, #path-1 do
            love.graphics.line(path[i][1], path[i][2], path[i+1][1], path[i+1][2])
        end 
    end

    if demo_stage > 0 then
        local s1, s2, vl1, vl2, vr1, vr2, nl1, nl2, nr1, nr2 = unpack(DEMONSTRATION[demo_stage])
        love.graphics.setColor(255, 0, 0)
        love.graphics.line(s1, s2, vl1, vl2)
        love.graphics.setColor(0, 255, 0)
        love.graphics.line(s1, s2, vr1, vr2)
        love.graphics.setColor(128, 0, 0)
        love.graphics.line(s1, s2, nl1, nl2)
        love.graphics.setColor(0, 128, 0)
        love.graphics.line(s1, s2, nr1, nr2)
    end

    -- for _, draw in pairs(DEBUG) do
    --     draw()
    -- end

    love.graphics.setColor(255, 255, 255)
    love.graphics.print(mx .. ", " .. my, 0, 0)
end