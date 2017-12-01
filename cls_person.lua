local Person = {}
Person.__index = Person

local default_speeds = {
    walking  = 64,
    running  = 96,
    sneaking = 32,
    hauling  = 24,
}

local movement = {
    WALKING  = "walking",
    SNEAKING = "sneaking",
    RUNNING  = "running",
    HAULING  = "hauling",
}
Person.movement = movement

function Person.new(options)
    local self = {}
    setmetatable(self, Person)

    self.name       = options.name       or ""
    self.position   = options.position   or {0, 0}
    self.direction  = options.direction  or 0
    self.size       = options.size       or 8
    self.speeds     = options.speed      or {}
    self.turn_speed = options.turn_speed or math.pi * 4

    self.facing   = self.direction
    self.movement = movement.WALKING
    self.idle     = true

    return self
end

function Person:speed()
    if not self.movement then 
        return 0 
    elseif self.speeds[self.movement] then
        return self.speeds[self.movement]
    else
        return default_speeds[self.movement]
    end
end

function Person:get_position()
    return unpack(self.position)
end

function Person:is_at(x, y, epsilon)
    return (x - self.position[1])^2 + (y - self.position[2])^2 <= (epsilon or 1)^2
end

function Person:move_towards(position, speed, dt)
    local ox, oy = self:get_position()
    local dx = position[1] - ox
    local dy = position[2] - oy
    local r = math.atan2(dy, dx)
    local mx = speed * dt * math.cos(r)
    local my = speed * dt * math.sin(r)
    self.position = {ox + mx, oy + my}
end

function Person:is_turned_towards(position, epsilon)
    local dr = math.atan2(position[2] - self.position[2], position[1] - self.position[1]) - self.direction
    return math.abs(dr) < (epsilon or math.pi / 16)
end

function Person:turn_towards(position, speed, dt)
    -- @TODO: have this be more sensible and always turn the shortest amount
    -- @TODO: also have this include facing if it's not possible (people are not owls)
    local dr = math.atan2(position[2] - self.position[2], position[1] - self.position[1]) - self.direction
    self.direction = self.direction + dr / math.abs(dr) * dt * speed
end

function Person:is_faced_towards(position, epsilon)
    local dr = math.atan2(position[2] - self.position[2], position[1] - self.position[1]) - self.facing
    return math.abs(dr) < (epsilon or math.pi / 16)
end

function Person:face_towards(position, speed, dt)
    -- @TODO: @SEE Person:turn_towards
    -- @TODO: what to do when this would requite turning body?
    local dr = math.atan2(position[2] - self.position[2], position[1] - self.position[1]) - self.facing
    self.facing = self.facing + dr / math.abs(dr) * dt * speed
end

function Person:draw()
    love.graphics.setColor(192, 192, 255)
    love.graphics.circle("fill", self.position[1], self.position[2], self.size)
    love.graphics.setColor(32, 32, 32)
    love.graphics.push()
    love.graphics.translate(unpack(self.position))
    love.graphics.arc("fill", 0, 0, self.size - 2, self.direction + math.pi / 2, self.direction + 3 * math.pi / 2)
    love.graphics.line(0, 0, 10 * math.cos(self.facing), 10 * math.sin(self.facing))
    love.graphics.pop()
end

return Person