local Noise = {}
Noise.__index = Noise

local FADE_SPEED = 255 * 4
local GROW_SPEED = 960

function Noise.new(options)
    local self = {}
    setmetatable(self, Noise)
    self.position = options.position 
    self.max_size = options.radius   or 128
    -- self.urgency  = options.urgency  or self.max_size * 8
    self.urgency  = GROW_SPEED

    self.radius    = 0
    self.listeners = {}
    self.finished  = false
    self.opacity   = 128

    return self
end

function Noise:update(dt, scene)
    if self.finished and self.opacity <= 0 then
        return
    elseif self.finished then 
        self.opacity = math.max(0, self.opacity - FADE_SPEED * dt)
        return 
    end

    self.radius = self.radius + self.urgency * dt

    if self.radius >= self.max_size then
        self.radius = self.max_size 
        self.finished = true
    end

    for _, obj in pairs(scene:objects_around_point(self.position, self.radius)) do
        if not self.listeners[obj] then
            self.listeners[obj] = true
            if obj.hear_noise then
                obj:hear_noise(unpack(self.position))
            end
        end
    end
end

function Noise:draw()
    if self.opacity <= 0 then return end
    love.graphics.setColor(128, 128, 255, self.opacity)
    love.graphics.circle("line", self.position[1], self.position[2], self.radius)
end

return Noise