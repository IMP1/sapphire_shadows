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

function Person.new(options)
    local this = {}
    setmetatable(this, Person)

    this.name      = options.name      or ""
    this.position  = options.position  or {0, 0}
    this.direction = options.direction or 0
    this.size      = options.size      or 8
    this.speeds    = options.speed     or {}

    this.movement = movement.WALKING
    this.idle     = true

    return this
end

function Person:speed()
    if not self.movement then return 0 end

    if self.speeds[self.movement] then
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

function Person:move_towards(x, y, speed, dt)
    local ox, oy = self:get_position()
    local dx = x - ox
    local dy = y - oy
    local r = math.atan2(dy, dx)
    local mx = speed * dt * math.cos(r)
    local my = speed * dt * math.sin(r)
    self.position = {ox + mx, oy + my}
end

function Person:draw()
    love.graphics.setColor(192, 192, 255)
    love.graphics.circle("fill", self.position[1], self.position[2], self.size)
    love.graphics.setColor(32, 32, 32)
    love.graphics.push()
    love.graphics.translate(unpack(self.position))
    love.graphics.line(0, 0, 10 * math.cos(self.direction), 10 * math.sin(self.direction))
    love.graphics.pop()
end

return Person