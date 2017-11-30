local Scene = {}
Scene.__index = Scene
function Scene:__tostring()
    return "Scene " .. self.name
end

function Scene.new(name)
    local this = {}
    setmetatable(this, Scene)
    this.name = name
    return this
end

function Scene:load()
    -- @stub 
end

function Scene:keyPressed(key, isRepeat)
    -- @stub 
end

function Scene:keyTyped(text)
    -- @stub 
end

function Scene:mousePressed(mx, my, key)
    -- @stub 
end

function Scene:mouseReleased(mx, my, key)
    -- @stub 
end

function Scene:update(dt, mx, my)
    -- @stub 
end

function Scene:draw()
    -- @stub 
end

function Scene:close()
    -- @stub 
end

return Scene
