local pathfinder = require 'lib_pathfinder'

local Guard = require 'cls_guard'
local Actor = require 'cls_character'
local Noise = require 'cls_noise'

local SceneBase = require 'scn_base'
local Scene = {}
setmetatable(Scene, SceneBase)
Scene.__index = Scene

function Scene.new()
    local self = {}
    setmetatable(self, Scene)

    self.map = {
        {32, 32, 24, 96, 128, 128, 96, 24},
        {96, 24, 128, 128, 200, 90, 192, 24},
        {192, 24, 200, 90, 244, 140, 300, 50},
        {24, 96, 32, 190, 128, 128},
        {244, 140, 270, 190, 350, 160, 300, 50},
        {244, 140, 190, 165, 210, 215, 270, 190},
        {32, 190, 60, 256, 160, 160, 128, 128},
        -- {},
    }
    pathfinder.map(self.map)

    self.people = {
        Guard.new({
            name = "foo",
            position = {80, 80},
            direction = 0,
            speed = {
                walking = 64,
            },
            patrol = {
                {170, 40}, {250, 70}, {80, 80}, 
            },
            viewcones = {
                {
                    width = math.pi / 4,
                    range = 96,
                    focus = true,
                },
                {
                    width = math.pi / 2,
                    range = 128,
                    focus = false,
                },
            },
        }),
    }
    self.party = {
        Actor.new({
            name = "john",
            position = {230, 180},
            direction = 0,
            speed = {
                walking = 64,
            },
        }),
    }

    self.noises = {}

    self.selected_character = 1
    self.character_action = nil
    self.action = nil

    return self
end

function Scene:objects_around_point(point, radius)
    -- @TODO: return a list of all (relevant?) objects in the circle
    local objects = {}
    for _, char in pairs(self.party) do
        local dx = char.position[1] - point[1] 
        local dy = char.position[2] - point[2] 
        if dx ^ 2 + dy ^ 2 < radius ^2 then
            table.insert(objects, char)
        end
    end
    for _, char in pairs(self.people) do
        local dx = char.position[1] - point[1] 
        local dy = char.position[2] - point[2] 
        if dx ^ 2 + dy ^ 2 < radius ^2 then
            table.insert(objects, char)
        end
    end
    return objects
end

function Scene:keyPressed(key)
    if key == "escape" then
        self.party[self.selected_character].path = nil
        self.character_action = nil
    end
    if key == "space" then
        self.party[self.selected_character]:toggle_sneak()
    end
    if key == "z" then
        self.character_action = "attack"
    end


    if key == "n" then
        self.action = "noise"
    end
    if key == "t" then
        self.action = "teleport"
    end
end

function Scene:mousePressed(mx, my, key)
    if key == 2 then
        if self.character_action then
            if self.character_action == "attack" then

            -- elseif self.character_action == "something else" then

            end


            self.character_action = nil
        else
            local path = pathfinder.path(self.party[self.selected_character].position, {mx, my})
            if path then
                self.party[self.selected_character].path = path
            end
        end
    end    

    if key == 1 and self.action then
        if self.action == "noise" then
            self:make_noise({mx, my}, 128)
        elseif self.action == "teleport" then
            self.party[self.selected_character].position = {mx, my}
        elseif self.action == "sighting" then
            
        elseif self.action == "distraction" then

        end
        self.action = nil
    end
end

function Scene:make_noise(position, noise_radius)
    local noise = Noise.new({
        position = position,
        radius   = noise_radius,
    })
    table.insert(self.noises, noise)
end

function Scene:update(dt)
    for _, p in pairs(self.people) do 
        p:update(dt, self) 
    end
    for _, p in pairs(self.party) do 
        p:update(dt, self) 
    end
    for _, n in pairs(self.noises) do
        n:update(dt, self)
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

function Scene:draw()
    local mx, my = love.mouse.getPosition()

    draw_map(self.map)

    for _, p in pairs(self.people) do 
        p:draw() 
        p:draw_vision()
    end
    for _, p in pairs(self.party) do 
        p:draw() 
    end
    for _, n in pairs(self.noises) do
        n:draw()
    end

    if self.selected_character then
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(self.party[self.selected_character].name, 460, 0) 
    end

    if self.character_action then
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(self.character_action, 460, 24) 
    end 

    if self.action then
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(self.action, 255, 0)
    end

    love.graphics.setColor(255, 255, 255)
    love.graphics.print(mx .. ", " .. my, 0, 0)
end

return Scene