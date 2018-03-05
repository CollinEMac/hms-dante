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
    if level ~= 0 and level ~= 100 and start_action == false and
        continue_story == false and #type_writer_c == #story_text then
            -- advance story text on enter or space or click
            continue_story = true
    elseif menu_selection == 1 then
        if level == 100 and story_text == "" then
            start_action = true
        end

        if level == 0 then
            level = 1
        end

        if level == 100 then
            level = unpause_level
        end

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
    end
end

function update.obstacle()
    if level == 1 then
        --TODO: This should probably involve what enemies have been created/destroyed
        -- Also, this shouldn't send to shader here, it should set a flag
        -- and if the flag is true then send shaders or whatever
        -- That way we can keep the shader active for a while
        if love.math.random(500) == 1 then -- random like 100 or something?
            incoming_obstacles[#incoming_obstacles + 1] = {
                y_min = 0.3,
                y_max = 0.4,
                time = love.timer.getTime()
            }
        end
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
        if (love.keyboard.isDown("up") or love.keyboard.isDown("w")) and
            player.y > 0 then
                player.y = player.y - player.speed
        end
        if (love.keyboard.isDown("left") or love.keyboard.isDown("a")) and
            player.x > 0 then
                player.x = player.x - player.speed
        end
        if (love.keyboard.isDown("down") or love.keyboard.isDown("s")) and
            player.y < window_height then
                player.y = player.y + player.speed
        end
        if (love.keyboard.isDown("right") or love.keyboard.isDown("d")) and
            player.x < window_width then
                player.x = player.x + player.speed
        end

        -- Expire the weapon after some time
        if love.timer.getTime() - player.weapon_time > 5 then
            player.weapon = ''
        end

    --TODO: will do this for level 1 too,
    -- scroll everything to the left at a constant rate
    -- that'll make things easier for changing speed too
    -- let the player move to the edge of the background
    elseif level == 2 and story_text == "" then
        vert_mid_of_cam = -cam.y + (window_height/2)
        hor_mid_of_cam = -cam.x + (window_width/2)

        if (love.keyboard.isDown("up") or love.keyboard.isDown("w")) then
            if cam.y < 0 and (player.y <= vert_mid_of_cam) then
                cam.y = cam.y + player.speed
            end
            if player.y > 0 then
                player.y = player.y - player.speed
            end
        end
        if (love.keyboard.isDown("left") or love.keyboard.isDown("a")) then
            if cam.x < 0 and (player.x <= hor_mid_of_cam) then
                cam.x = cam.x + player.speed
            end
            if player.x > 0 then
                player.x = player.x - player.speed
            end
        end
        if (love.keyboard.isDown("down") or love.keyboard.isDown("s")) then
            if cam.y - window_height > -(background.image:getHeight()) and
                (player.y >= vert_mid_of_cam) then
                    cam.y = cam.y - player.speed
            end
            if player.y < window_height + (-cam.y) then -- this is confusing as heck because cam.y is negative
                player.y = player.y + player.speed
            end
        end
        if (love.keyboard.isDown("right") or love.keyboard.isDown("d")) then
            if cam.x - window_width > -(background.image:getWidth()) and
                (player.x >= hor_mid_of_cam) then
                    cam.x = cam.x - player.speed
            end
            if player.x < window_width + (-cam.x) then -- this is confusing as heck because cam.x is negative
                player.x = player.x + player.speed
            end
        end
    end
end

function update.projectiles(projectiles, dt)
    if level == 1 then
        for i, projectile in ipairs(projectiles) do
            if 0 < projectile.x and
                0 - (window_height/4) < projectile.y and
                projectile.x < window_width and
                projectile.y < (window_height + (window_height/4)) then

                    projectile.x = projectile.x + projectile.dx * projectile.speed

                    if projectile.weapon == 'sin' then
                        projectile.time = projectile.time + dt
                        projectile.y = projectile.y +
                                         (projectile.dy * projectile.speed) +
                                         ((window_height/60) * math.sin(2 * math.pi * projectile.time))
                    else
                        projectile.y = projectile.y + projectile.dy * projectile.speed
                    end

                    object_hit(projectile, i)
            else
                table.remove(projectiles, i)
            end
        end
    end
end

function update.ufo(dt)
    for i, ufo in ipairs(ufos) do
        if ufo.x + (UFO_SIZE_CF * ufo.image:getWidth()) > 0 and
            ufo.y + (UFO_SIZE_CF * ufo.image:getHeight()) > 0 then

                if ufo.toward_player == true then
                    ufo.x = ufo.x - ufo.speed -- move to the left

                    if ufo.x < player.x - 50 then
                        ufo.toward_player = false
                    end
                else
                    ufo.x = ufo.x + ufo.speed -- move to the right

                    if ufo.x > window_width - 50 then
                        ufo.toward_player = true
                    end
                end

                -- don't allow ufos to go off screen (destroy ones that do manually)
                if ufo.y <= UFO_SIZE_CF * (ufo.image:getHeight()/2) then
                    ufo.y = ufo.y + 1
                elseif ufo.y >= window_height - (UFO_SIZE_CF * ufo.image:getHeight()) then
                    ufo.y = ufo.y - 1
                else
                    -- handle vertical movement patterns
                    if ufo.movement_pattern == 'sin' then
                        -- THIS IS CAUSING HUGE PERFORMANCE ISSUES AND FREEZES THE GAME UP!
                        ufo.time = ufo.time + dt
                        ufo.y = ufo.y + 0.4 * math.sin(ufo.time)
                    end

                    if ufo.movement_pattern == 'random' then
                        -- random y axis movement
                        if love.math.random(50) == 1 then
                            -- Randomly change y movement direction (up/down)
                            ufo.y_delta = -ufo.y_delta
                        end

                        ufo.y = ufo.y + ufo.y_delta
                    end
                end

                -- kill player on contact with ufo
                object_hit(ufo, 0)
                create_ufo_projectiles(ufo)
        else
            table.remove(ufos, i)
        end
    end
end

function action()
    -- call events like spawning enemies
    -- spawn just the first ufo in the
    if level == 1 then
        if ufo_counter == 0 then
            spawn_ufo('random')
        end

        -- spawn a second ufo
        if ufo_counter == 1 then
            now = love.timer.getTime()

            if #ufos > 0 then
                -- TODO: Want to tweak this, won't spawn until 2 are defeated
                if now > ufos[#ufos].create_time + 2 then
                    spawn_ufo('random')
                end
            else
                spawn_ufo('random')
            end
        end

        if #ufos <= 2 and ufo_counter == 2 then
            now = love.timer.getTime()

            if now > ufo_destroyed + 2 then
                spawn_ufo('random')
            end
        end
    end
end

function spawn_ufo(movement_pattern)
    -- Percent of y axis the ufo will appear on
    y_percent = love.math.random(1, 9) * 0.1

    -- add a new ufo to the list
    new_ufo = {image = love.graphics.newImage("sprites/ufo.jpg"),
        x = 0,
        y = y_percent * window_height,
        speed = 1,
        time = 0,
        friendly = false,
        movement_pattern = movement_pattern,
        weapon_prob = 10,
        toward_player = true,
        y_delta = 1, -- Move up or down on y axis? default down
        create_time = love.timer.getTime() -- for timed events like firing projectiles
    }

    -- Have to do this later because it references the object image
    new_ufo.x = window_width + (UFO_SIZE_CF * new_ufo.image:getWidth()/2)

    ufos[#ufos + 1] = new_ufo

    ufo_counter = ufo_counter + 1
end

function update.create_player_projectiles()
    if level == 1 then
        player_lasers[#player_lasers + 1] = {image = love.graphics.newImage("sprites/laser.jpg"),
            x = player.x,
            y = player.y,
            weapon = player.weapon, -- set to sin to test sin pattern
            time = 0,
            speed = 7,
            friendly = true,
            dx = math.cos(player.rotation - PLAYER_IMG_ROTATION_CF),
            dy = math.sin(player.rotation - PLAYER_IMG_ROTATION_CF)
        }

        last_player_laser_create = love.timer.getTime()
    end
end

function create_ufo_projectiles(ufo)
    -- create a projectile every div seconds for variation
    div = love.math.random(3, 5)
    time = utils.round((love.timer.getTime() - ufo.create_time), 0)

    if time % div == 0 and #ufo_lasers < 1 then
        local direction = math.atan2((ufo.y - player.y), (ufo.x - player.x))

        ufo_lasers[#ufo_lasers + 1] = {image = love.graphics.newImage("sprites/laser.jpg"),
            x = ufo.x,
            y = ufo.y,
            weapon = 'sin',
            time = 0,
            friendly = false,
            dx = math.cos(direction),
            dy = math.sin(direction),
            speed = -3
        }
    end
end

function update.npcs()
    if level == 2 and #npcs == 0 then
        -- create npc
        npc1 = {image = CHARACTER_PLAYER,
            name = 'npc1',
                x = window_width / 2,
                y = window_height + 10,
                speech = {[1] = 'Hey, I\'m an NPC!'
                }
            }

            npcs[#npcs+1] = npc1
        end
    end

    function update.story(char)
        --Write story text if time is correct and last_story text cleared (enter or space)
        -- later this will depend on time/level
    advance_text(char)

    if start_action == true then
        action()
    end
end

function advance_text(char)
    now = love.timer.getTime()
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
            character = char.name
            story_text = STORY_TEXTS[4]
            continue_story = false
        end

        if start_action == false and continue_story == true and story_text == STORY_TEXTS[4] then
            type_writer_c = ""
            character = "narrator"
            story_text = STORY_TEXTS[1]
            start_action = true
            continue_story = false
        end
    elseif level == 2 and char then
        if continue_story == true and story_text == STORY_TEXTS[1] then
            type_writer_c = ""
            character = char.name
            story_text = char.speech[1]
            continue_story = false
        end

        if continue_story == true and story_text == char.speech[1] then
            type_writer_c = ""
            character = "narrator"
            story_text = STORY_TEXTS[1]
            continue_story = false
            start_action = true
        end
    end

    if (now > type_writer_time + 0.05) and #type_writer_c < #story_text then
        -- TODO: Allow for changing this speed in options menu
        type_writer_c = story_text:sub(1, #type_writer_c + 1)
        type_writer_time = now
    end
end

function object_hit(projectile, projectile_i)
    -- Checks if projecile is overlapping an object and destroys it

    if projectile.friendly == true then
        for i, ufo in ipairs(ufos) do
            if utils.overlap(projectile, ufo, PLAYER_PROJECTILE_SIZE_CF, UFO_SIZE_CF) then
                -- if player projectile overlapping enemy then destroy it

                if #ufos <= 2 and ufo_counter == 2 then
                    ufo_destroyed = love.timer.getTime()
                end

                spawn_weapon(ufo)
                table.remove(ufos, i)
                table.remove(player_lasers, projectile_i)
                player_score = player_score + 10
            end
        end
    else
        if utils.overlap(projectile, player, ENEMY_PROJECTILE_SIZE_CF, PLAYER_PROJECTILE_SIZE_CF) then
            -- if projectile overlapping player then YOU DEAD!
            game_over()
        end
    end
end

function spawn_weapon(ufo)
    -- spawn a weapon on enemy death sometimes
    if love.math.random(ufo.weapon_prob) == 1 then
        -- spawn the weapon in a giant downward sine wave where it gets destroyed
        weapons[#weapons + 1] = {image = love.graphics.newImage("sprites/gun.jpg"),
            x = ufo.x,
            y = ufo.y,
            type = 'sin',
            time = 0
        }
    end
end

function update.weapons(dt)
    -- TODO: Something wrong here, seems like I get the weapon even if I don't
    -- object hit it (moving too fast?)
    if level == 1 then
        for i, weapon in ipairs(weapons) do
            if 0 < weapon.x and
                0 < weapon.y and
                weapon.x < window_width and
                weapon.y < window_height then

                    weapon.x = weapon.x - 3

                    weapon.time = weapon.time + dt
                    weapon.y = weapon.y + (window_height/30) * math.sin(weapon.time)
            else
                table.remove(weapons, i)
            end

            -- check if player is picking up the weapon
            if utils.overlap(weapon, player, ENEMY_PROJECTILE_SIZE_CF, PLAYER_PROJECTILE_SIZE_CF) then
                -- TODO: Need to account for correction factor of both sprites!
                player.weapon = weapon.type
                player.weapon_time = love.timer.getTime()
                table.remove(weapons, i)
            end
        end
    end
end

function game_over()
    -- Stop Drawing all objects except game over text
    player.alive = false
end

return update
