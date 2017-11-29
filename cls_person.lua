local person = {}
person.__index = person

function person.new(options)
    local this = {}
    setmetatable(this, person)

    this.name      = options.name      or ""
    this.position  = options.position  or {0, 0}
    this.direction = options.direction or 0

    return this
end

function person:get_position()
    return unpack(self.position)
end

function person:is_at(x, y, epsilon)
    return (x - self.position[1])^2 + (y - self.position[2])^2 <= (epsilon or 1)^2
end

function person:draw()
    love.graphics.setColor(192, 192, 255)
    love.graphics.circle("fill", self.position[1], self.position[2], 8)
    love.graphics.setColor(32, 32, 32)
    love.graphics.push()
    love.graphics.translate(unpack(self.position))
    love.graphics.line(0, 0, 10 * math.cos(self.direction), 10 * math.sin(self.direction))
    love.graphics.pop()
end

return person