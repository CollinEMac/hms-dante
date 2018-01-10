-- Update function update.s

update = {}

function update.background()
    -- move the background Flintstones style
    if background.x > - background.image:getWidth() + love.graphics.getWidth() then
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
    if (love.keyboard.isDown("down") or love.keyboard.isDown("s")) and player.y < love.graphics.getHeight() then
        player.y = player.y + player.speed
    end
    if (love.keyboard.isDown("right") or love.keyboard.isDown("d")) and player.x < love.graphics.getWidth() then
        player.x = player.x + player.speed
    end
end

function update.player_projectiles()
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

function update.ufo(dt)
    for i, ufo in ipairs(ufos) do
        if 0 < ufo.x + (UFO_SIZE_CF * ufo.image:getWidth()) and
            0 < ufo.y + (UFO_SIZE_CF * ufo.image:getHeight()) and
            ufo.y < love.graphics.getHeight() - (UFO_SIZE_CF * ufo.image:getHeight()) then

                ufo.x = ufo.x + ufo.speed

                if ufo.movement_pattern == 'sin' then
                    ufo_time = ufo_time + dt
                    ufo.y = ufo.y + 0.4 * math.sin(ufo_time)
                end

                update_ufo_projectiles(ufo)
        else
            table.remove(ufos, i)
        end
    end
end

function update.trigger_timed_events()
    -- call time based events like spawning enemies or initiating bosses
    time = love.timer.getTime() - start
    -- spawn just the first ufo in the
    if time > 3.0 and ufo_counter == 0 then
        spawn_ufo('sin', 0.167)
    end

    -- spawn a second ufo
    if time > 5.0 and ufo_counter == 1 then
        spawn_ufo('straight', 0.833)
    end
end

function spawn_ufo(movement_pattern, y_percent)
    -- add a new ufo to the list
    ufos[#ufos + 1] = {image = love.graphics.newImage("sprites/ufo.jpg"),
        x = love.graphics.getWidth(), --spawn offscreen and move in
        y = y_percent * love.graphics.getHeight(),
        speed = -1,
        movement_pattern = movement_pattern,
        create_time = love.timer.getTime(), -- for timed events like firing projectiles
        projectiles = {}
    }

    ufo_counter = ufo_counter + 1
end

function update_ufo_projectiles(ufo)
    time = utils.round((love.timer.getTime() - ufo.create_time), 0)

    -- TODO: maybe make this happen every so often?
    -- Like every rand(3, 10) seconds make ufo shoot?
    if time % 5 == 0 and #ufo.projectiles < 1 then
        local direction = math.atan2((ufo.y - player.y), (ufo.x - player.x))

        --TODO: projectiles can't be an attribute of ufo or else they destroy when the ufo destroys
        ufo.projectiles[#ufo.projectiles + 1] = {image = love.graphics.newImage("sprites/laser.jpg"),
            x = ufo.x,
            y = ufo.y,
            dx = math.cos(direction),
            dy = math.sin(direction)
        }
    end

    for i, projectile in ipairs(ufo.projectiles) do
        if 0 < projectile.x and
            0 < projectile.y and
            projectile.x < love.graphics.getWidth() and
            projectile.y < love.graphics.getHeight() then
                projectile.x = projectile.x - (projectile.dx * PLAYER_PROJECTILE_SPEED) -- player projectile speed for now
                projectile.y = projectile.y - (projectile.dy * PLAYER_PROJECTILE_SPEED) -- TODO: vary projectile speed
                object_hit(false, projectile)
        else
            table.remove(ufo.projectiles, i)
        end
    end
end

function object_hit(player_friendly, projectile)
    -- Checks if projecile is overlapping an object an destroys it

    if player_friendly == true then
        -- if it's a friendly projectile then check enemies
        for i, ufo in ipairs(ufos) do
            -- TODO: Tighten up hitboxes
            if projectile.x > (ufo.x - (UFO_SIZE_CF * ufo.image:getWidth()/2)) and
                projectile.x < (ufo.x + (UFO_SIZE_CF * ufo.image:getWidth())) and
                projectile.y > (ufo.y - (UFO_SIZE_CF * ufo.image:getHeight()/2)) and
                projectile.y < (ufo.y + (UFO_SIZE_CF * ufo.image:getHeight())) then

                    -- if player projectile overlapping enemy then destroy it
                    table.remove(ufos, i)
                    player_score = player_score + 10
                    -- table.remove(player.projectiles,)
                    -- TODO: need to destroy the  player projectile too
            end
        end
    else
        -- if it's an enemy projectile then check player
        if projectile.x > (player.x - (PROJECTILE_SIZE_CF * player.image:getWidth())/2) and -- might want to make edges of player their own attributes
            projectile.x < (player.x + (PROJECTILE_SIZE_CF * player.image:getWidth())) and
            projectile.y > (player.y - (PROJECTILE_SIZE_CF * player.image:getHeight())/2) and
            projectile.y < (player.y + (PROJECTILE_SIZE_CF * player.image:getHeight())) then
                -- if player projectile overlapping player then destroy it
                -- this is a little funky, not sure what's going on
                player.alive = false
        end
    end
end

return update
