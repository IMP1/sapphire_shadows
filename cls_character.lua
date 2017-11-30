local pathfinder = require 'lib_pathfinder'

local Person = require 'cls_person'

local Character = {}
setmetatable(Character, Person)
Character.__index = Character

function Character.new(options)
    local this = Person.new(options)
    setmetatable(this, Character)

    this.is_sneaking = false

    return this
end

function Character:toggle_sneak()
    -- @TODO: make sure the Character can actually start or stop sneaking (e.g. is hauling a body)
    self.is_sneaking = not self.is_sneaking
    if self.is_sneaking then
        self.movement = "sneaking"
    else
        self.movement = "walking"
    end
end

local function update_movement(self, dt)
    local next_point = self.path[1]
    if self:is_at(next_point[1], next_point[2], 5) then
        table.remove(self.path, 1)
        if #self.path == 0 then
            self.path = nil
        end
    else
        local x, y = self:get_position()
        local dx = next_point[1] - x
        local dy = next_point[2] - y
        local r = math.atan2(dy, dx)
        local mx = self:speed() * dt * math.cos(r)
        local my = self:speed() * dt * math.sin(r)
        self.position = {x + mx, y + my}
    end
end

function Character:update(dt)
    if self.path then
        update_movement(self, dt)
    end
end

function Character:draw()
    Person.draw(self)

    if self.is_sneaking then
        love.graphics.setColor(32, 32, 32, 128)
    else
        love.graphics.setColor(255, 255, 255, 128)
    end
    love.graphics.circle("line", self.position[1], self.position[2], self.size + 2)

    if DEBUG then
        if self.path then
            love.graphics.setColor(255, 0, 255)
            love.graphics.line(self.position[1], self.position[2], self.path[1][1], self.path[1][2])
            for i = 1, #self.path - 1 do
                love.graphics.line(self.path[i][1], self.path[i][2], self.path[i+1][1], self.path[i+1][2])
            end
        end
    end
end

return Character