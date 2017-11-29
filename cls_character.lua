local pathfinder = require 'lib_pathfinder'

local person = require 'cls_person'

local character = {}
setmetatable(character, person)
character.__index = character

function character.new(options)
    local this = person.new(options)
    setmetatable(this, character)

    return this
end

function character:speed()
    -- @TODO: have different speeds (also include stuff like carrying bodies, etc.)
    -- if self.is_crouching then
    --     return self.speed_crouching
    -- else 
    --     return self.speed_walking
    -- end
    return 64
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

function character:update(dt)
    if self.path then
        update_movement(self, dt)
    end
end

function character:draw()
    person.draw(self)

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

return character