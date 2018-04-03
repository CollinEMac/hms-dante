-- Draw Functions

draw = {}

shaders = require("shaders")

function draw.menu(type)
    -- Draws a menu, takes a string defining if 'main' menu or 'pause' menu
    menu_selection_x = 0.25 * window_width
    if menu_selection == 1 then
        menu_selection_y = 0.25 * window_height
    elseif menu_selection == 2 then
        menu_selection_y = 0.50 * window_height
    elseif menu_selection == 3 then
        menu_selection_y = 0.75 * window_height
    end

    if type == 'main' then
        game_text = 'Start Game'
    elseif type == 'pause' then
        game_text = 'Resume'
    end

    love.graphics.rectangle('fill', menu_selection_x, menu_selection_y, 10, 10)
    love.graphics.printf(game_text, 0, 0.25 * window_height, window_width, "center")
    love.graphics.printf('Options', 0, 0.50 * window_height, window_width, "center")
    love.graphics.printf('Quit Game', 0, 0.75 * window_height, window_width, "center")
end

function draw.background()
    love.graphics.setShader(red_shader)
    love.graphics.draw(background.image,
        background.x,
        background.y
    )
    love.graphics.setShader()
end

function draw.obstacles()
    for i, incoming_obstacle in ipairs(incoming_obstacles) do
        if utils.time_check(incoming_obstacle.time, 3) then
            red_shader:send("y_min", incoming_obstacle.y_min)
            red_shader:send("y_max", incoming_obstacle.y_max)
        else
            red_shader:send("y_min", 0)
            red_shader:send("y_max", 0)
            table.remove(incoming_obstacles, i)
        end
    end
end

function draw.player()
    if player.alive == true then
        love.graphics.draw(player.image,
            player.x,
            player.y,
            player.rotation,
            1,
            1,
            player.image:getWidth()/2,
            player.image:getHeight()/2
        )
    end
end

function draw.player_hitbox() -- for testing purposes
    -- Draws a circular hitbox
    if player.alive == true then
        love.graphics.circle('line',
        player.x,
        player.y,
        player.image:getHeight()/2)
    end
end

function draw.crosshair()
    if player.alive == true then
        love.graphics.setColor(255, 0, 0) -- red dot
        love.graphics.circle("fill",
            player.x + (math.cos(player.rotation) * player.image:getWidth() * 0.75),
            player.y + (math.sin(player.rotation) * player.image:getWidth() * 0.75),
            window_width/100)
        love.graphics.setColor(255, 255, 255) -- default white
    end
end

function draw.projectile()
    for i, player_laser in ipairs(player_lasers) do
        love.graphics.draw(player_laser.image,
            player_laser.x,
            player_laser.y,
            3 * math.pi / 2,
            1,
            1,
            player_laser.image:getWidth()/2,
            player_laser.image:getHeight()/2
        )
    end
end

function draw.ufos()
    for i, ufo in ipairs(ufos) do
        now = love.timer.getTime()
        if ufo.fade_time > 0 then
            love.graphics.setShader(fade_shader)
            fade_saturation = now - ufo.fade_time
            if fade_saturation < 3 then
                fade_shader:send("saturation", fade_saturation)
            else
                fade_shader:send("saturation", 0)
            end
        end

        if ufo.death_time > 0 then
            love.graphics.setShader(death_shader)
            death_saturation = now - ufo.death_time
            death_shader:send("saturation", death_saturation)
        end

        love.graphics.draw(ufo.image,
            ufo.x,
            ufo.y,
            0,
            1,
            1,
            ufo.image:getWidth()/2,
            ufo.image:getHeight()/2
        )

        utils.clear_all_shaders()
    end
end

function draw.npcs()
    if level == 2 then
        for i, npc in ipairs(npcs) do
            love.graphics.draw(npc.image,
                npc.x,
                npc.y,
                0,
                1,
                1,
                player.image:getWidth()/2,
                player.image:getHeight()/2
            )
        end
    end
end

function draw.text()
    if story_text ~= STORY_TEXTS[1] then
        -- get the values sides of the text box
        left_most_text_box = (0.05 * window_width) - cam.x
        right_most_text_box = (0.95 * window_width) - cam.x
        bottom_of_text_box = (0.95 * window_height) - cam.y
        top_of_text_box = (0.75 * window_height) - cam.y

        text_box_width = right_most_text_box - left_most_text_box
        text_box_height = bottom_of_text_box - top_of_text_box

        -- define the text box
        text_box_vertex = {
            { left_most_text_box, bottom_of_text_box, 0, 0, 190, 190, 190, 255 }, -- top left vertex
            { right_most_text_box, bottom_of_text_box, 0, 0, 190, 190, 190, 100 }, -- top right vertex
            { right_most_text_box, top_of_text_box, 0, 0, 190, 190, 190, 255 }, -- bottom right vertex
            { left_most_text_box,top_of_text_box, 0, 0, 190, 190, 190, 100 } -- bottom left vertex
        }


        if text_box == nil then
            text_box = love.graphics.newMesh(text_box_vertex, "fan", "static")
        else
            text_box:setVertices(text_box_vertex, 1)
        end

        love.graphics.draw(text_box)

        -- show story text during story moments
        if character ~= 'narrator' then
            text = character .. ': ' .. type_writer_c
        else
            text = type_writer_c
        end

        love.graphics.printf(
            text,
            left_most_text_box + (0.05 * text_box_width),
            top_of_text_box + (0.10 * text_box_height),
            right_most_text_box - (0.15 * text_box_width),
            "left"
        )
    end

    if level == 1 then
        love.graphics.print(player_score, 0.9 * window_width, 0.04 * window_height)
    end
end

function draw.ufo_projectiles()
    for i, ufo_laser in ipairs(ufo_lasers) do
        love.graphics.draw(ufo_laser.image,
            ufo_laser.x,
            ufo_laser.y,
            3 * math.pi / 2,
            1,
            1,
            ufo_laser.image:getWidth()/2,
            ufo_laser.image:getHeight()/2
        )
    end
end

function draw.weapons()
    for i, weapon in ipairs(weapons) do
        love.graphics.draw(weapon.image,
            weapon.x,
            weapon.y,
            0,
            1,
            1,
            weapon.image:getWidth()/2,
            weapon.image:getHeight()/2
        )
    end
end

function draw.game_over_text()
    love.graphics.printf('Game Over', 0, 0.5 * window_height, window_width, "center")
end

return draw
