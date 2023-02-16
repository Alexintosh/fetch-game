local sti = require("/lib/sti")
local anim8 = require("/lib/anim8/anim8")
local player = {}
local ground = 0
local jumpSpeed = 700
local jumpHeight = 200
local gravity = -9
local gameStarted = false

function love.load()
    camera = require("/lib/hump/camera")
    gameMap = sti('/maps/testMap.lua')
    W, H, flags = love.window.getMode( )
    
    player.h = 128
    player.w = 128
    player.x = 0
    player.y = H - player.h

    cam = camera(0, H);

    ground = player.y
    player.speed = 400
    player.sprite = love.graphics.newImage("assets/llama_walk.png")
    player.grid = anim8.newGrid(128, 128, player.sprite:getWidth(), player.sprite:getHeight())
    player.animations = {}

    player.animations.top = anim8.newAnimation( player.grid('1-4', 1), 0.2)
    player.animations.left = anim8.newAnimation( player.grid('1-4', 2), 0.2)
    player.animations.down = anim8.newAnimation( player.grid('1-4', 3), 0.2)
    player.animations.right = anim8.newAnimation( player.grid('1-4', 4), 0.2)

    player.anim = player.animations.right

    player.states = {
        running = 1,
        jumping = 2,
        falling = 3,
        dead = 4,
    }

    player.state = player.states.running

end

function love.update(dt)
    if love.mouse.isDown(1) then
        gameStarted = true
    end

    if love.keyboard.isDown("r") then
        love.event.quit( "restart" )
    end

    cam:lookAt(player.x + W/4, cam.y)

    if cam.x < W/2 then
        cam.x = W/2
    end
    cam.y = H - H/2

    if gameStarted then
        player:update(dt)
    end

    
end

function love.draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["ground"])
        gameMap:drawLayer(gameMap.layers["trees"])
        
        player.anim:draw(player.sprite, player.x, player.y)

        love.graphics.print(player.y, 10, 10)
        love.graphics.print(ground - jumpSpeed * 5.5, 10, 35)
    cam:detach()
    
end


function isJumping()
    return player.state == player.states.jumping
end

function isRunning()
    return player.state == player.states.running
end

function isFalling()
    return player.state == player.states.falling
end

function player:update(dt)
    local jumpMaxHeight = ground - jumpHeight

    if gameStarted == false then
        player.anim:gotoFrame(1)
    else
        player.x = player.x + (player.speed * dt)
    end

    -- TODO: make it so you can't jump before you hit the ground again
    if love.keyboard.isDown("space") and player.state == player.states.running then
        player.state = player.states.jumping
        player.anim:gotoFrame(1)
    end

    -- Jump apex
    if isJumping() then
        if player.y > jumpMaxHeight then 
            player.y = player.y - (jumpSpeed * dt)
        else
            player.state = player.states.falling
        end
    end

    if isFalling() then
        if player.y < ground then
            player.y = player.y + (jumpSpeed * dt)
        else
            player.state = player.states.running
        end
    end

    player.anim:update(dt)
end