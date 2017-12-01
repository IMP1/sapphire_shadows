local pathfinder = require 'lib_pathfinder'

local Person = require 'cls_person'

local Character = {}
setmetatable(Character, Person)
Character.__index = Character

function Character.new(options)
    local self = Person.new(options)
    setmetatable(self, Character)

    self.is_sneaking = false

    return self
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
    if not self:is_turned_towards(next_point) then
        self:turn_towards(next_point, self.turn_speed, dt)
        return
    end

    if self:is_at(next_point[1], next_point[2], 5) then
        table.remove(self.path, 1)
        if #self.path == 0 then
            self.path = nil
        end
    else
        self:move_towards(next_point, self:speed(), dt)
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
            love.graphics.line(self.position[1] + 10 * math.cos(self.direction), self.position[2] + 10 * math.sin(self.direction), 
                               self.path[1][1], self.path[1][2])
            for i = 1, #self.path - 1 do
                love.graphics.line(self.path[i][1], self.path[i][2], self.path[i+1][1], self.path[i+1][2])
            end
        end
    end
end

return Character