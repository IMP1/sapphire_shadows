local pathfinder = require 'lib_pathfinder'

local Person = require 'cls_person'
local Actor  = require 'cls_character'

local Guard = {}
setmetatable(Guard, Person)
Guard.__index = Guard

function Guard.new(options)
    local this = Person.new(options)
    setmetatable(this, Guard)

    this.viewcones   = options.viewcones    or {}
    this.watch_width = options.watch_width or math.pi / 4
    this.watch_speed = options.watch_speed or math.pi / 2

    this.watch_direction = this.direction
    this.watch_timer     = 0
    this.behaviour       = "patrol"

    this.max_view_distance = 0
    for _, v in pairs(this.viewcones) do
        if v.range > this.max_view_distance then
            this.max_view_distance = v.range
        end
    end

    return this
end

function Guard:hear_noise(x, y)
    print("heard a noise.")
    self.behaviour = "suspicious"
end

local function update_movement(self, dt)
    local next_point = self.path[1]
    if self:is_at(next_point[1], next_point[2], 5) then
        table.remove(self.path, 1)
        if #self.path == 0 then
            self.path = nil
        end
    else
        self:move_towards(next_point[1], next_point[2], self:speed(), dt)
    end
end

local function update_watch(self, dt, scene)
    self.watch_timer = self.watch_timer + dt
    self.watch_direction = self.watch_width * math.sin(self.watch_timer * self.watch_speed)

    local objects = scene:objects_around_point(self.position, self.max_view_distance)
    if #objects > 0 then
        for _, obj in pairs(objects) do
            if getmetatable(obj) == Actor then

                -- @TODO: make sure object is in cone (rather than distance) and can be seen.
                self.behaviour = "suspicious"
            end
        end
    else
        self.behaviour = "patrol"
    end
end

function Guard:update(dt, scene)
    if self.behaviour == "patrol" then
        if self.path then
            update_movement(self, dt)
        end
        update_watch(self, dt, scene)
    elseif self.behaviour == "suspicious" then
        update_watch(self, dt, scene)
    end
end

function Guard:draw_vision()
    for _, viewcone in pairs(self.viewcones) do
        -- @TODO: draw an arc, filled
        if viewcone.focus then
            love.graphics.setColor(32, 255, 32, 128)
        else
            love.graphics.setColor(32, 255, 32, 96)
        end
        local r1 = self.watch_direction - viewcone.width / 2
        local r2 = self.watch_direction + viewcone.width / 2
        love.graphics.arc("fill", self.position[1], self.position[2], viewcone.range, r1, r2)
        if self.behaviour == "suspicious" and viewcone.focus then
            love.graphics.setColor(255, 32, 32, 128)
            love.graphics.arc("fill", self.position[1], self.position[2], viewcone.range, r1, r2)
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