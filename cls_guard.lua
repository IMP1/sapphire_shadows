local pathfinder = require 'lib_pathfinder'
local geometry   = require 'util_geometry'

local Person = require 'cls_person'
local Actor  = require 'cls_character'

local Guard = {}
setmetatable(Guard, Person)
Guard.__index = Guard

local behaviours = {
    SUSPICIOUS = 1,
    PATROL     = 2,
    INSPECTING = 3,
    ALERTED    = 4,
    ENGAGING   = 5,
}
Guard.behaviours = behaviours

function Guard.new(options)
    local self = Person.new(options)
    setmetatable(self, Guard)

    self.viewcones       = options.viewcones    or {}
    self.watch_width     = options.watch_width or math.pi / 4
    self.watch_speed     = options.watch_speed or math.pi / 2
    self.suspicion_speed = 64

    self.watch_timer         = 0
    self.behaviour           = behaviours.PATROL
    self.suspicion_meter     = 0
    self.suspicious_object   = nil
    self.suspicious_position = nil

    self.max_view_distance = 0
    for _, v in pairs(self.viewcones) do
        if v.range > self.max_view_distance then
            self.max_view_distance = v.range
        end
    end

    return self
end

function Guard:can_see(position, is_hard_to_see)
    for _, viewcone in pairs(self.viewcones) do
        local r1 = self.facing - viewcone.width / 2
        local r2 = self.facing + viewcone.width / 2
        if (viewcone.focus or not is_hard_to_see) and
           geometry.sector_contains_point(self.position, r1, r2, viewcone.range, position) then
            return true
        end
    end
    return false
end

function Guard:hear_noise(position, object)
    self.behaviour = behaviours.SUSPICIOUS
    self.suspicious_object = object
    self.suspicious_position = position
end

local function update_patrol(self, dt, scene)
    if self.path then
        local next_point = self.path[1]
        if self:is_at(next_point[1], next_point[2], 5) then
            table.remove(self.path, 1)
            if #self.path == 0 then
                self.path = nil
            end
        else
            self:move_towards(next_point, self:speed(), dt)
        end
    end
    self.watch_timer = self.watch_timer + dt

    local watch_target = {
        self.position[1] + math.cos(self.direction + self.watch_width * math.sin(self.watch_timer * self.watch_speed)),
        self.position[2] + math.sin(self.direction + self.watch_width * math.sin(self.watch_timer * self.watch_speed)),
    }
    self:face_towards(watch_target, self.watch_speed, dt)
    -- self.facing = self.watch_width * math.sin(self.watch_timer * self.watch_speed)

    for _, viewcone in pairs(self.viewcones) do
        local objects = scene:objects_in_cone(self.position, viewcone, self.facing)
        for _, obj in pairs(objects) do
            if getmetatable(obj) == Actor then
                self.behaviour = behaviours.SUSPICIOUS
                self.suspicious_object = obj
                self.suspicious_position = obj.position
            end
        end
        
    end
end

local function update_suspicion(self, dt, scene)
    if not self:is_faced_towards(self.suspicious_position) then
        self:face_towards(self.suspicious_position, self.turn_speed, dt)
    elseif self.suspicious_object then
        local hard_to_see = self.suspicious_object.is_sneaking
        if self:can_see(self.suspicious_object.position, hard_to_see) then
            self.suspicion_meter = self.suspicion_meter + dt * self.suspicion_speed
            if geometry.distance_squared(self.position, self.suspicious_object.position) <= self.suspicion_meter ^ 2 then
                
                if getmetatable(self.suspicious_object) == Actor then
                    self.behaviour = behaviours.ENGAGING
                else                    
                    self.behaviour = behaviours.ALERTED
                end

            end
        else
            self.suspicion_meter = self.suspicion_meter - dt * self.suspicion_speed
            if self.suspicion_meter <= 0 then
                self.suspicion_meter = 0
                self.behaviour = behaviours.PATROL
            end
        end
        
    elseif self.suspicion_meter == 0 then
        self.suspicion_meter = 1
    else
        self.suspicion_meter = self.suspicion_meter - dt
        if self.suspicion_meter <= 0 then
            self.suspicion_meter = 0
            self.behaviour = behaviours.PATROL
        end
    end
end

local function update_inspection(self, dt, scene)
    
end 

function Guard:update(dt, scene)
    if self.behaviour == behaviours.ENGAGING then

    elseif self.behaviour == behaviours.ALERTED then

    elseif self.behaviour == behaviours.INSPECTING then

    elseif self.behaviour == behaviours.SUSPICIOUS then
        update_suspicion(self, dt, scene)
    elseif self.behaviour == behaviours.PATROL then
        update_patrol(self, dt, scene)
    end
end

function Guard:draw_vision()
    for _, viewcone in pairs(self.viewcones) do
        if viewcone.focus then
            love.graphics.setColor(32, 255, 32, 128)
        else
            love.graphics.setColor(32, 255, 32, 96)
        end
        local r1 = self.facing - viewcone.width / 2
        local r2 = self.facing + viewcone.width / 2
        love.graphics.arc("fill", self.position[1], self.position[2], viewcone.range, r1, r2)

        if viewcone.focus and self.suspicion_meter > 0 then
            love.graphics.setColor(255, 32, 32, 128)
            love.graphics.arc("fill", self.position[1], self.position[2], self.suspicion_meter, r1, r2)
        end
    end
end

function Guard:draw()
    Person.draw(self)

    if DEBUG then
        if self.patrol then
            love.graphics.setColor(0, 64, 64)
            local n = #self.patrol
            love.graphics.line(self.patrol[n][1], self.patrol[n][2], self.patrol[1][1], self.patrol[1][2])
            for i = 1, #self.patrol - 1 do
                love.graphics.line(self.patrol[i][1], self.patrol[i][2], self.patrol[i+1][1], self.patrol[i+1][2])
            end
        end

        if self.path then
            love.graphics.setColor(0, 255, 255)
            love.graphics.line(self.position[1], self.position[2], self.path[1][1], self.path[1][2])
            for i = 1, #self.path - 1 do
                love.graphics.line(self.path[i][1], self.path[i][2], self.path[i+1][1], self.path[i+1][2])
            end
        end
    end
end

return Guard