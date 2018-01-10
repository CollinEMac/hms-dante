-- Draw Functions

draw = {}

function draw.draw_background()
    love.graphics.draw(background.image,
        background.x,
        background.y
    )
end

function draw.draw_player()
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

function draw.draw_projectile()
    for i, player_laser in ipairs(player_lasers) do
        love.graphics.draw(player_laser.image,
            player_laser.x,
            player_laser.y,
            3 * math.pi / 2,
            PROJECTILE_SIZE_CF,
            PROJECTILE_SIZE_CF
        )
    end
end

function draw.draw_ufos()
    for i, ufo in ipairs(ufos) do
        love.graphics.draw(ufo.image,
            ufo.x,
            ufo.y,
            0,
            UFO_SIZE_CF,
            UFO_SIZE_CF
        )
        draw_ufo_projectiles(ufo)
    end
end

function draw.draw_text()
    love.graphics.print(player_score, 0.9 * love.graphics.getWidth(), 0.04 * love.graphics.getHeight())
end

function draw_ufo_projectiles(ufo)
    for i, ufo_laser in ipairs(ufo.projectiles) do
        love.graphics.draw(ufo_laser.image,
            ufo_laser.x,
            ufo_laser.y,
            3 * math.pi / 2,
            PROJECTILE_SIZE_CF,
            PROJECTILE_SIZE_CF
        )
    end
end

return draw