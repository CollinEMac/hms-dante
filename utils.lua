-- Simple functions and tedious calculations

local utils={}

function utils.get_player_rotation()
    -- returns the players rotation in radians
    player.rotation = math.atan2((mouse_y - player.y), (mouse_x - player.x))
end

function utils.round(num, numDecimalPlaces)
    -- round num to defined number of places
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function utils.overlap(first_sprite, second_sprite)

    half_first_sprite_w = first_sprite.image:getWidth()/2
    half_first_sprite_h = first_sprite.image:getHeight()/2
    half_second_sprite_w = second_sprite.image:getWidth()/2
    half_second_sprite_h = second_sprite.image:getHeight()/2

    -- If a sprite is the player then do circular hitbox
    if second_sprite.rotation ~= nil then
        -- Find corners of first_sprite
        -- This should be a table dear god, then do a for loop holy shit
        upper_left_x = first_sprite.x - half_first_sprite_w
        upper_left_y = first_sprite.y - half_first_sprite_w
        upper_right_x = first_sprite.x + half_first_sprite_w
        upper_right_y = first_sprite.y - half_first_sprite_w
        lower_left_x = first_sprite.x - half_first_sprite_w
        lower_left_y = first_sprite.y + half_first_sprite_w
        lower_right_x = first_sprite.x + half_first_sprite_w
        lower_right_y = first_sprite.y + half_first_sprite_w

        r2 = math.pow((player.image:getHeight()/2), 2) -- Seems like a good size

        -- Equation of a circle
        -- (x−h)^2+(y−k)^2=r^2

        if (math.pow((upper_left_x - second_sprite.x), 2) + math.pow((upper_left_y - second_sprite.y), 2) < r2) or
            (math.pow((upper_right_x - second_sprite.x), 2) + math.pow((upper_right_y - second_sprite.y), 2) < r2) or
            (math.pow((lower_left_x - second_sprite.x), 2) + math.pow((lower_left_y - second_sprite.y), 2) < r2) or
            (math.pow((lower_right_x - second_sprite.x), 2) + math.pow((lower_right_y - second_sprite.y), 2) < r2) then
                return true
        end

    -- checks to see if two rectangular ssprites are overlapping each other
    elseif (first_sprite.x + half_first_sprite_w) > (second_sprite.x - half_second_sprite_w) and
        (first_sprite.x - half_first_sprite_w) < (second_sprite.x + half_second_sprite_w) and
        (first_sprite.y + half_first_sprite_h) > (second_sprite.y - half_second_sprite_h) and
        (first_sprite.y - half_first_sprite_h) < (second_sprite.y + half_second_sprite_h) then
            return true
    end

    return false
end

function utils.time_check(event, wait_time)
    -- Returns bool, true if enough time has passed since that event
    if love.timer.getTime() > event + wait_time then
        return true
    else
        return false
    end
end

function utils.clear_all_shaders()
    while (love.graphics.getShader() ~= nil)
        do
            love.graphics.setShader()
        end
end

return utils
