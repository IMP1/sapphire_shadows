local pathfinder = require 'lib_pathfinder'

local person = require 'cls_person'

local guard = {}
setmetatable(guard, person)
guard.__index = guard

function guard.new(options)
    local this = person.new(options)
    setmetatable(this, guard)

    this.viewcones = {
        {
            width = math.pi / 16,
            range = 64,
            focus = true,
        },
    } -- @TODO: make this dependent on options
    this.patrol = options.patrol or nil
    this.patrol_stage = 0

    return this
end

function guard:speed()
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

function guard:update(dt)
    if self.patrol and not self.path then
        self.patrol_stage = self.patrol_stage + 1
        if self.patrol_stage > #self.patrol then
            self.patrol_stage = 1
        end
        self.path = pathfinder.path(self.position, self.patrol[self.patrol_stage])
    end
    if self.path then
        update_movement(self, dt)
    end
end

function guard:draw_viewcones()
    for _, viewcone in pairs(self.viewcones) do
        -- @TODO: draw an arc, filled
    end
end

function guard:draw()
    person.draw(self)

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

return guard