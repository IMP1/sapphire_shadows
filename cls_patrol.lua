local Patrol = {}
Patrol.__index = Patrol

function Patrol.new(options)
    local this = {}
    setmetatable(this, Patrol)

    return this
end

function Patrol:update(dt)

end

return Patrol