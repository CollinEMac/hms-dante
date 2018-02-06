-- Draw Functions

draw = {}

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
    love.graphics.draw(background.image,
        background.x,
        background.y
    )
end

function draw.player()
    if player.alive == true then
        love.graphics.draw(player.image,
            player.x,
            player.y,
            player.rotation,
            PROJECTILE_SIZE_CF,
            PROJECTILE_SIZE_CF,
            player.image:getWidth()/2,
            player.image:getHeight()/2
        )
    end
end

function draw.projectile()
    for i, player_laser in ipairs(player_lasers) do
        love.graphics.draw(player_laser.image,
            player_laser.x,
            player_laser.y,
            3 * math.pi / 2,
            PROJECTILE_SIZE_CF,
            PROJECTILE_SIZE_CF,
            player_laser.image:getWidth()/2,
            player_laser.image:getHeight()/2
        )
    end
end

function draw.ufos()
    for i, ufo in ipairs(ufos) do
        love.graphics.draw(ufo.image,
            ufo.x,
            ufo.y,
            0,
            UFO_SIZE_CF,
            UFO_SIZE_CF,
            ufo.image:getWidth()/2,
            ufo.image:getHeight()/2
        )
    end
end

function draw.npcs()
    if level == 2 then
        for i, npc in ipairs(npcs) do
            love.graphics.draw(npc.image,
                npc.x,
                npc.y,
                0,
                PROJECTILE_SIZE_CF,
                PROJECTILE_SIZE_CF,
                player.image:getWidth()/2,
                player.image:getHeight()/2
            )
        end
    end
end

function draw.text()
    if story_text ~= STORY_TEXTS[1] then
        -- I don't need to recreate this every time. I could just update teh vertices each frame
        -- TODO: misc performance issues

        -- get the values sides of the text box
        left_most_text_box = (0.05 * window_width) - cam.x
        right_most_text_box = (0.95 * window_width) - cam.x
        bottom_of_text_box = (0.95 * window_height) - cam.y
        top_of_text_box = (0.75 * window_height) - cam.y

        text_box_width = right_most_text_box - left_most_text_box
        text_box_height = bottom_of_text_box - top_of_text_box

        -- define the text box
        text_box_vertex = {
            { left_most_text_box, bottom_of_text_box, 0, 0, 190, 190, 190, 100 }, -- top left vertex
            { right_most_text_box, bottom_of_text_box, 0, 0, 190, 190, 190, 100 }, -- top right vertex
            { right_most_text_box, top_of_text_box, 0, 0, 190, 190, 190, 100 }, -- bottom right vertex
            { left_most_text_box,top_of_text_box, 0, 0, 190, 190, 190, 100 } -- bottom left vertex
        }

        text_box = love.graphics.newMesh(text_box_vertex, "fan", "static")

        love.graphics.draw(text_box)

        -- show story text during story moments
        if character ~= 'narrator' then
            text = character .. ': ' .. type_writer_c
        else
            text = type_writer_c
        end

        -- TODO: if i use cam for level 1 too then we won't have to check here I guess
        love.graphics.printf(text, left_most_text_box + (0.05 * text_box_width), top_of_text_box + (0.10 * text_box_height),  right_most_text_box - (0.05 * text_box_width))
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
            PROJECTILE_SIZE_CF,
            PROJECTILE_SIZE_CF,
            ufo_laser.image:getWidth()/2,
            ufo_laser.image:getHeight()/2
        )
    end
end

function draw.game_over_text()
    love.graphics.printf('Game Over', 0, 0.5 * window_height, window_width, "center")
end

return draw
