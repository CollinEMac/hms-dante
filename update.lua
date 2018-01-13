-- Update function update.s

update = {}

function update.background()
    -- move the background Flintstones style
    if background.x > - background.image:getWidth() + window_width then
        background.x = background.x - 3
    else
        background.x = 0
    end
end

function update.player()
    -- Handle player movement
    mouse_x, mouse_y = love.mouse.getPosition()
    utils.get_player_rotation()

    if (love.keyboard.isDown("up") or love.keyboard.isDown("w")) and player.y > 0 then
        player.y = player.y - player.speed
    end
    if (love.keyboard.isDown("left") or love.keyboard.isDown("a")) and player.x > 0 then
        player.x = player.x - player.speed
    end
    if (love.keyboard.isDown("down") or love.keyboard.isDown("s")) and player.y < window_height then
        player.y = player.y + player.speed
    end
    if (love.keyboard.isDown("right") or love.keyboard.isDown("d")) and player.x < window_width then
        player.x = player.x + player.speed
    end
end

function update.player_projectiles()
    for i, player_laser in ipairs(player_lasers) do
        if 0 < player_laser.x and
            0 < player_laser.y and
            player_laser.x < window_width and
            player_laser.y < window_height then

                player_laser.x = player_laser.x + player_laser.dx * PLAYER_PROJECTILE_SPEED
                player_laser.y = player_laser.y + player_laser.dy * PLAYER_PROJECTILE_SPEED

                object_hit(true, player_laser, i)
        else
            table.remove(player_lasers, i)
        end
    end
end

function update.ufo(dt)
    for i, ufo in ipairs(ufos) do
        if ufo.x + (UFO_SIZE_CF * ufo.image:getWidth()) > 0 and
            ufo.y + (UFO_SIZE_CF * ufo.image:getHeight()) > 0 and
            ufo.y < window_height - (UFO_SIZE_CF * ufo.image:getHeight()) then

                ufo.x = ufo.x + ufo.speed

                if ufo.movement_pattern == 'sin' then
                    ufo_time = ufo_time + dt
                    ufo.y = ufo.y + 0.4 * math.sin(ufo_time)
                end

                -- kill player on contact with ufo
                object_hit(false, ufo, 0)
                create_ufo_projectiles(ufo)
        else
            table.remove(ufos, i)
        end
    end
end

function update.trigger_timed_events()
    -- TODO: break these out into thier own functions, this is terrible
    -- call time based events like spawning enemies or initiating bosses
    time = love.timer.getTime() - start

    --Write story text
    if time > 1.0 and continue_story == true then
        story_text = "Story Text"
        if time > 2.0 then
            continue_story = false -- TODO: finish this
        end
    end

    -- spawn just the first ufo in the
    if time > 10.0 and ufo_counter == 0 then
        spawn_ufo('sin', 0.167)
    end

    -- spawn a second ufo
    if time > 13.0 and ufo_counter == 1 then
        spawn_ufo('straight', 0.833)
    end

end

function spawn_ufo(movement_pattern, y_percent)
    -- add a new ufo to the list
    -- new_ufo = ()
    new_ufo = {image = love.graphics.newImage("sprites/ufo.jpg"),
        x = 0,
        y = y_percent * window_height,
        speed = -1,
        movement_pattern = movement_pattern,
        create_time = love.timer.getTime() -- for timed events like firing projectiles
    }

    new_ufo.x = window_width + (UFO_SIZE_CF * new_ufo.image:getWidth()/2)

    ufos[#ufos + 1] = new_ufo

    ufo_counter = ufo_counter + 1
end

function update.create_player_projectiles()
    player_lasers[#player_lasers + 1] = {image = love.graphics.newImage("sprites/laser.jpg"),
        x = player.x,
        y = player.y,
        dx = math.cos(player.rotation - PLAYER_IMG_ROTATION_CF),
        dy = math.sin(player.rotation - PLAYER_IMG_ROTATION_CF)
    }

    last_player_laser_create = love.timer.getTime()
end

function create_ufo_projectiles(ufo)
    time = utils.round((love.timer.getTime() - ufo.create_time), 0)

    if time % 5 == 0 and #ufo_lasers < 1 then
        local direction = math.atan2((ufo.y - player.y), (ufo.x - player.x))

        ufo_lasers[#ufo_lasers + 1] = {image = love.graphics.newImage("sprites/laser.jpg"),
            x = ufo.x,
            y = ufo.y,
            dx = math.cos(direction),
            dy = math.sin(direction)
        }
    end
end

function update.ufo_projectiles()
    for i, ufo_laser in ipairs(ufo_lasers) do
        -- ufo_lasers are getting progressively faster for each one in the list?
        if 0 < ufo_laser.x and
            0 < ufo_laser.y and
            ufo_laser.x < window_width and
            ufo_laser.y < window_height then
                ufo_laser.x = ufo_laser.x - ufo_laser.dx * PLAYER_PROJECTILE_SPEED
                ufo_laser.y = ufo_laser.y - ufo_laser.dy * PLAYER_PROJECTILE_SPEED -- TODO: vary projectile speed
                object_hit(false, ufo_laser, 0)
        else
            table.remove(ufo_lasers, i)
        end
    end
end

function object_hit(player_friendly, projectile, projectile_i)
    -- Checks if projecile is overlapping an object an destroys it

    if player_friendly == true then
        -- if it's a friendly projectile then check enemies
        for i, ufo in ipairs(ufos) do
            if projectile.x > (ufo.x - (UFO_SIZE_CF * ufo.image:getWidth()/2)) and
                projectile.x < (ufo.x + (UFO_SIZE_CF * ufo.image:getWidth())) and
                projectile.y > (ufo.y - (UFO_SIZE_CF * ufo.image:getHeight()/2)) and
                projectile.y < (ufo.y + (UFO_SIZE_CF * ufo.image:getHeight())) then

                    -- if player projectile overlapping enemy then destroy it
                    table.remove(ufos, i)
                    table.remove(player_lasers, projectile_i)
                    player_score = player_score + 10
            end
        end
    else
        -- if it's an enemy projectile then check player
        if projectile.x > (player.x - (PROJECTILE_SIZE_CF * player.image:getWidth()/2)) and -- might want to make edges of player their own attributes
            projectile.x < (player.x + (PROJECTILE_SIZE_CF * player.image:getWidth())) and
            projectile.y > (player.y - (PROJECTILE_SIZE_CF * player.image:getHeight()/2)) and
            projectile.y < (player.y + (PROJECTILE_SIZE_CF * player.image:getHeight())) then
                -- if projectile overlapping player then destroy it
                game_over()
        end
    end
end

function game_over()
    -- Stop Drawing all objects except game over text
    player.alive = false
end

return update
