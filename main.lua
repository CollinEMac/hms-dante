-- A little side scrolling shooter

-- Correction for the image, it's tilted to the side
PLAYER_IMG_ROTATION_CF = 0.75 * math.pi
UFO_SIZE_CF = 0.15
PLAYER_PROJECTILE_SIZE_CF = 0.1
PLAYER_PROJECTILE_SPEED = 7

function love.load()
    -- Initial setup
    love.window.setMode(600, 600)

    background = {image = love.graphics.newImage("sprites/background.jpg"),
        x = 0,
        y = 0
    }

    player = {image = love.graphics.newImage("sprites/spaceship.png"),
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() / 2
    }

    player_lasers = {}
    ufos = {}
    ufo_time = 0


    start = love.timer.getTime()
end

function love.mousereleased(x, y, button)
    --https://yal.cc/love2d-shooting-things/
    --https://stackoverflow.com/questions/19957846/love2d-how-to-make-bullets

    -- Create a laser
    player_lasers[#player_lasers + 1] = {image = love.graphics.newImage("sprites/laser.jpg"),
        x = player.x,
        y = player.y,
        dx = math.cos(player.rotation - PLAYER_IMG_ROTATION_CF),
        dy = math.sin(player.rotation - PLAYER_IMG_ROTATION_CF)
    }
end

function love.update(dt)
    update_background()
    update_player()
    update_player_projectiles()
    trigger_timed_events()
    update_ufo(dt)
end

function update_background()
    -- move the background Flintstones style
    if background.x > - background.image:getWidth() + love.graphics.getWidth() then
        background.x = background.x - 3
    else
        background.x = 0
    end
end

function update_player()
    -- Handle player movement
    -- Add a button to adjust player speed
    mouse_x, mouse_y = love.mouse.getPosition()
    get_player_rotation()
    player_speed = 5

    if (love.keyboard.isDown("up") or love.keyboard.isDown("w")) and player.y > 0 then
        player.y = player.y - player_speed
    end
    if (love.keyboard.isDown("left") or love.keyboard.isDown("a")) and player.x > 0 then
        player.x = player.x - player_speed
    end
    if (love.keyboard.isDown("down") or love.keyboard.isDown("s")) and player.y < love.graphics.getHeight() then
        player.y = player.y + player_speed
    end
    if (love.keyboard.isDown("right") or love.keyboard.isDown("d")) and player.x < love.graphics.getWidth() then
        player.x = player.x + player_speed
    end
end

function update_player_projectiles()
    for i, player_laser in ipairs(player_lasers) do
        if 0 < player_laser.x and
            0 < player_laser.y and
            player_laser.x < love.graphics.getWidth() and
            player_laser.y < love.graphics.getHeight() then

                player_laser.x = player_laser.x + player_laser.dx * PLAYER_PROJECTILE_SPEED
                player_laser.y = player_laser.y + player_laser.dy * PLAYER_PROJECTILE_SPEED

                object_hit(true, player_laser)
        else
            table.remove(player_lasers, i)
        end
    end
end

function update_ufo(dt)
    for i, ufo in ipairs(ufos) do
        if 0 < ufo.x + (UFO_SIZE_CF * ufo.image:getWidth()) and
            0 < ufo.y + (UFO_SIZE_CF * ufo.image:getHeight()) and
            ufo.y < love.graphics.getHeight() - (UFO_SIZE_CF * ufo.image:getHeight()) then

                ufo.x = ufo.x + ufo.speed

                if ufo.movement_pattern == 'sin' then
                    -- TODO: Adjust amplitude, it's a little big
                    ufo_time = ufo_time + dt
                    ufo.y = ufo.y + math.sin(ufo_time)
                end
        else
            table.remove(ufos, i)
        end
    end
end

function update_ufo_projectiles()
    --object_hit(false, ufo_laser?)
end

function get_player_rotation()
    -- returns the players rotation in radians
    player.rotation = math.atan2((mouse_y - player.y), (mouse_x - player.x)) + PLAYER_IMG_ROTATION_CF
end

function object_hit(player_friendly, projectile)
    -- Checks if projecile is overlapping an object an destroys it

    if player_friendly then
        -- if it's a friendly projectile then check enemies
        for i, ufo in ipairs(ufos) do
            if projectile.x > ufo.x and
                projectile.x < (ufo.x + (UFO_SIZE_CF * ufo.image:getWidth())) and
                projectile.y > ufo.y and
                projectile.y < (ufo.y + (UFO_SIZE_CF * ufo.image:getHeight())) then

                    -- if player projectile overlapping enemy then destroy it
                    table.remove(ufos, i)
                    -- need to destroy the projectile too
            end
        end
    else
        -- if it's an enemy projectile then check player
        if projectile.x > player.x and
            projectile.x < (player.x + (UFO_SIZE_CF * player.image:getWidth())) and
            projectile.y > player.y and
            projectile.y < (player.y + (UFO_SIZE_CF * player.image:getHeight())) then

                -- if player projectile overlapping player then destroy it
            print('Handle game over stuff')
        end
    end
end

function trigger_timed_events()
    -- call time based events like spawning enemies or initiating bosses
    time = love.timer.getTime() - start
    -- spawn just the first ufo in the game
    if time > 3.0 and time < 3.1 and #ufos == 0 then
        spawn_ufo('sin', 100)
    end

    -- spawn a second ufo
    if time > 5.0 and time < 5.1 and #ufos < 2 then
        spawn_ufo('straight', 500)
    end
end

function spawn_ufo(movement_pattern, y)
    -- add a new ufo to the list (takes a Y component for location)
    ufos[#ufos + 1] = {image = love.graphics.newImage("sprites/ufo.jpg"),
        x = love.graphics.getWidth(), --spawn offscreen and move in
        y = y,
        speed = -2,
        movement_pattern = movement_pattern
    }
end

function love.draw()
    draw_background()
    draw_player()
    draw_projectile()
    draw_ufos()
end

function draw_background()
    love.graphics.draw(background.image,
        background.x,
        background.y
        -- height stuff
    )
end

function draw_player()
    love.graphics.draw(player.image,
        player.x,
        player.y,
        player.rotation,
        PLAYER_PROJECTILE_SIZE_CF,
        PLAYER_PROJECTILE_SIZE_CF,
        player.image:getWidth()/2,
        player.image:getHeight()/2
    )
end

function draw_projectile()
    for i, player_laser in ipairs(player_lasers) do
        love.graphics.draw(player_laser.image,
            player_laser.x,
            player_laser.y,
            3 * math.pi / 2,
            PLAYER_PROJECTILE_SIZE_CF,
            PLAYER_PROJECTILE_SIZE_CF
            -- TODO: Set the x and y offsets so that projectile shows up right in front of the player's nose.
            -- (player_laser.image:getWidth()/2 - player.image:getWidth()/2),
            -- (player_laser.image:getHeight()/2 - player.image:getHeight()/2)
        )
    end
end

function draw_ufos()
    for i, ufo in ipairs(ufos) do
        love.graphics.draw(ufo.image,
            ufo.x,
            ufo.y,
            0,
            UFO_SIZE_CF,
            UFO_SIZE_CF
        )
    end
end

function draw_ufo_projectiles()
end
