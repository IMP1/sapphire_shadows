local SceneManager = {}

local current_scene = nil
local scene_stack = {}

local function closeScene()
    if current_scene then
        current_scene:close()
    end
end

local function loadScene()
    if current_scene then
        current_scene:load()
    end
end

function SceneManager.scene()
    return current_scene
end

function SceneManager.setScene(new_scene, clear_stack)
    if clear_stack then
        while #scene_stack > 0 do
            SceneManager.popScene()
        end
    end
    closeScene()
    current_scene = new_scene
    loadScene()
end

function SceneManager.pushScene(new_scene)
    table.insert(scene_stack, current_scene)
    current_scene = new_scene
    loadScene()
end

function SceneManager.popScene()
    closeScene()
    current_scene = table.remove(scene_stack)
end

------------------------------------------------
-- Methods to pass along to relevant scene(s) --
------------------------------------------------
function SceneManager.keypressed(key, is_repeat)
    if current_scene and current_scene.keyPressed then 
        current_scene:keyPressed(key, is_repeat)
    end
    for _, scene in pairs(scene_stack) do
        if scene and scene.backgroundKeyPressed then
            scene:backgroundKeyPressed()
        end
    end
end

function SceneManager.keyreleased(key, is_repeat)
    if current_scene and current_scene.keyReleased then 
        current_scene:keyReleased(key, is_repeat)
    end
    for _, scene in pairs(scene_stack) do
        if scene and scene.backgroundKeyReleased then
            scene:backgroundKeyReleased()
        end
    end
end

function SceneManager.keytyped(text)
    if current_scene and current_scene.keyTyped then
        current_scene:keyTyped(text)
    end
    for _, scene in pairs(scene_stack) do
        if scene and scene.backgroundKeyTyped then
            scene:backgroundKeyTyped()
        end
    end
end

function SceneManager.mousepressed(mx, my, key)
    if current_scene and current_scene.mousePressed then
        current_scene:mousePressed(mx, my, key)
    end
    for _, scene in pairs(scene_stack) do
        if scene and scene.backgroundMousePressed then
            scene:backgroundMousePressed()
        end
    end
end

function SceneManager.mousereleased(mx, my, key)
    if current_scene and current_scene.mouseReleased then
        current_scene:mouseReleased(mx, my, key)
    end
    for _, scene in pairs(scene_stack) do
        if scene and scene.backgroundMouseReleased then
            scene:backgroundMouseReleased()
        end
    end
end

function SceneManager.update(dt)
    local mx, my = love.mouse.getPosition()
    if current_scene and current_scene.update then
        current_scene:update(dt, mx, my)
    end
    for _, scene in pairs(scene_stack) do
        if scene and scene.backgroundUpdate then
            scene:backgroundUpdate()
        end
    end
end

function SceneManager.draw()
    if current_scene and current_scene.draw then
        current_scene:draw()
    end
    for _, scene in pairs(scene_stack) do
        if scene and scene.backgroundDraw then
            scene:backgroundDraw()
        end
    end
end

function SceneManager.close()
    if current_scene and current_scene.close then
        current_scene:close()
    end
    for _, scene in pairs(scene_stack) do
        if scene and scene.backgroundClose then
            scene:backgroundClose()
        end
    end
end

return SceneManager