-- Draw Functions

draw = {}


-- Synopsis
--
-- love.graphics.draw( drawable, x, y, r, sx, sy, ox, oy, kx, ky )
--
-- Arguments
--
-- Drawable drawable
--     A drawable object.
-- number x (0)
--     The position to draw the object (x-axis).
-- number y (0)
--     The position to draw the object (y-axis).
-- number r (0)
--     Orientation (radians).
-- number sx (1)
--     Scale factor (x-axis).
-- number sy (sx)
--     Scale factor (y-axis).
-- number ox (0)
--     Origin offset (x-axis).
-- number oy (0)
--     Origin offset (y-axis).

--The origin is the upper left corner of the newImage
-- The origin should be set to the center, that's why I'm struggeling with
-- hit detection

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
    love.graphics.print(player_score, 0.9 * window_width, 0.04 * window_height)

    -- show story text during story moments
    if start_action == false then
        love.graphics.print(story_text, 0.25 * window_width, 0.8 * window_height)
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
    align = AlignMode
    love.graphics.printf('Game Over', 0, 0.5 * window_height, window_width, "center")
end

return draw
