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

function draw.text()
    if story_text ~= "" then
        text_box_vertex = {
            { 0.05 * window_width, 0.75 * window_height, 0, 0, 190, 190, 190, 100 }, -- top left vertex
            { 0.95 * window_width, 0.75 * window_height, 0, 0, 190, 190, 190, 100 }, -- top right vertex
            { 0.95 * window_width, 0.95 * window_height, 0, 0, 190, 190, 190, 100 }, -- bottom right vertex
            { 0.05 * window_width, 0.95 * window_height, 0, 0, 190, 190, 190, 100 } -- bottom left vertex
        }

        text_box = love.graphics.newMesh(text_box_vertex, "fan", "static")

        love.graphics.draw(text_box)
    end

    love.graphics.print(player_score, 0.9 * window_width, 0.04 * window_height)

    -- show story text during story moments
    if start_action == false then
        if character then
            text = character .. ': ' .. type_writer_c
        else
            text = type_writer_c
        end

        love.graphics.printf(text, 0.15 * window_width, 0.80 * window_height, 0.75 * window_width)

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
