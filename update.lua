-- Update function update.s

update = {}

function update.menu()
    -- Handles menu stuff
    mouse_y = love.mouse.getY()
    if mouse_y < 0.33 * window_height then
        -- first menu selection is selected
        menu_selection = 1
    elseif (0.33 * window_height) < mouse_y and mouse_y < (0.67 * window_height) then
        -- second menu selection is selected
        menu_selection = 2
    else
        -- third menu selection is selected
        menu_selection = 3
    end
end

function update.select_menu_item()
    -- Handle menu button selections and story continue but only one or the other
    if level ~= 0 and level ~= 100 and start_action == false and continue_story == false and #type_writer_c == #story_text then
        -- advance story text on enter or space or click
        continue_story = true
    elseif menu_selection == 1 then
        if level == 100 and story_text == "" then
            start_action = true
        end

        level = 1

    elseif menu_selection == 2 then
        -- TODO: add settings and options
        print('options')
    elseif menu_selection == 3 then
        love.event.quit()
    end

    if player.alive == false then
        -- Handle game over screen (navigate back to main menu)
        level = 0
        player.alive = true
    end

end

function update.background(stage)
    if level == 1 then
        background.image = SPACE_BACKGROUND
        -- move the background Flintstones style
        if background.x > - background.image:getWidth() + window_width then
            background.x = background.x - 3
        else
            background.x = 0
        end
    -- I'm just going to handle the rpg segments as a separate level
    -- elseif level == 2 then
    --     --TODO: remove this and us love.graphics.translate
    --     -- handle rpg player movement
    --     if (love.keyboard.isDown("right") or love.keyboard.isDown("d")) then
    --         background.x = background.x - player.speed
    --         love.graphics.translate(-player.x, 0)
    --     elseif (love.keyboard.isDown("left") or love.keyboard.isDown("a")) then
    --         background.x = background.x + player.speed
    --     end
    --
    --     if (love.keyboard.isDown("up") or love.keyboard.isDown("w")) then
    --         background.y = background.y + player.speed
    --     elseif (love.keyboard.isDown("down") or love.keyboard.isDown("s")) then
    --         background.y = background.y - player.speed
    --     end
    end
end

function update.cam()
    --TODO: remove this and us love.graphics.translate
    -- handle rpg player movement
    if (love.keyboard.isDown("right") or love.keyboard.isDown("d")) then
        cam.x = cam.x - player.speed
        love.graphics.translate(-player.x, 0)
    elseif (love.keyboard.isDown("left") or love.keyboard.isDown("a")) then
        cam.x = cam.x + player.speed
    end

    if (love.keyboard.isDown("up") or love.keyboard.isDown("w")) then
        cam.y = cam.y + player.speed
    elseif (love.keyboard.isDown("down") or love.keyboard.isDown("s")) then
        cam.y = cam.y - player.speed
    end
end

function update.player()
    -- Handle player movement
    if level == 1 then
        mouse_x, mouse_y = love.mouse.getPosition()
        utils.get_player_rotation()
    elseif level == 2 then
        player.image = CHARACTER_PLAYER
        player.rotation = 0
    end

    if level == 1 then
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
    elseif level == 2 then
        if (love.keyboard.isDown("right") or love.keyboard.isDown("d")) then
            player.x = player.x - player.speed
            love.graphics.translate(-player.x, 0)
        elseif (love.keyboard.isDown("left") or love.keyboard.isDown("a")) then
            player.x = player.x + player.speed
        end

        if (love.keyboard.isDown("up") or love.keyboard.isDown("w")) then
            player.y = player.y + player.speed
        elseif (love.keyboard.isDown("down") or love.keyboard.isDown("s")) then
            player.y = player.y - player.speed
        end
    end
end

function update.player_projectiles()
    if level == 1 then
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

function action()
    -- call events like spawning enemies
    -- spawn just the first ufo in the
    if ufo_counter == 0 then
        spawn_ufo('sin', 0.167)
        last_ufo_spawn = love.timer.getTime()
    end

    -- spawn a second ufo
    if ufo_counter == 1 then
        now = love.timer.getTime()

        if now > last_ufo_spawn + 2 then
            spawn_ufo('straight', 0.833)
        end
    end
end

function spawn_ufo(movement_pattern, y_percent)
    -- add a new ufo to the list
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
    if level == 1 then
        player_lasers[#player_lasers + 1] = {image = love.graphics.newImage("sprites/laser.jpg"),
            x = player.x,
            y = player.y,
            dx = math.cos(player.rotation - PLAYER_IMG_ROTATION_CF),
            dy = math.sin(player.rotation - PLAYER_IMG_ROTATION_CF)
        }

        last_player_laser_create = love.timer.getTime()
    end
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

function update.npcs()
    if level == 2 and #npcs == 0 then
        -- create npc
        -- TODO: draw off screen npc
        npc1 = {image = CHARACTER_PLAYER,
            x = window_width / 2,
            y = window_height + 10,
        }

        npcs[#npcs+1] = npc1
    end
end

function update.story()
    --Write story text if time is correct and last_story text cleared (enter or space)
    -- later this will depend on time/level
    advance_text()

    if start_action == true then
        action()
    end
end

function advance_text()
    if level == 1 then
        now = love.timer.getTime()
        if start_action == false and continue_story == true and story_text == STORY_TEXTS[1] then
            type_writer_c = ""
            story_text = STORY_TEXTS[2]
            continue_story = false
        end

        if start_action == false and continue_story == true and story_text == STORY_TEXTS[2] then
            type_writer_c = ""
            story_text = STORY_TEXTS[3]
            continue_story = false
        end

        if start_action == false and continue_story == true and story_text == STORY_TEXTS[3] then
            type_writer_c = ""
            character = CHARACTERS['dante']
            story_text = STORY_TEXTS[4]
            continue_story = false
        end

        if start_action == false and continue_story == true and story_text == STORY_TEXTS[4] then
            type_writer_c = ""
            character = ""
            story_text = STORY_TEXTS[1]
            start_action = true
            continue_story = false
        end

        if (now > type_writer_time + 0.05) and #type_writer_c < #story_text then
            -- TODO: Allow for changing this speed in options menu
            type_writer_c = story_text:sub(1, #type_writer_c + 1)
            type_writer_time = now
        end

    end
end

function object_hit(player_friendly, projectile, projectile_i)
    -- Checks if projecile is overlapping an object and destroys it

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
