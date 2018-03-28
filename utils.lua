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
    -- Note: this might create issues with projectiles that are bigger
    -- than the player
    if second_sprite.rotation ~= nil then
        -- Find corners of first_sprite
        first_sprite_corners = {}

        -- upper left
        first_sprite_corners[#first_sprite_corners + 1] = {
            x = first_sprite.x - half_first_sprite_w,
            y = first_sprite.y - half_first_sprite_w
        }

        -- upper right
        first_sprite_corners[#first_sprite_corners + 1] = {
            x = first_sprite.x + half_first_sprite_w,
            y = first_sprite.y - half_first_sprite_w
        }

        -- lower left
        first_sprite_corners[#first_sprite_corners + 1] = {
            x = first_sprite.x - half_first_sprite_w,
            y = first_sprite.y + half_first_sprite_w
        }

        -- lower right
        first_sprite_corners[#first_sprite_corners + 1] = {
            x = first_sprite.x + half_first_sprite_w,
            y = first_sprite.y + half_first_sprite_w
        }

        for i, corner in ipairs(first_sprite_corners) do

            -- Equation of a circle
            -- (x−h)^2+(y−k)^2=r^2
            if (math.pow((corner.x - second_sprite.x), 2) + math.pow((corner.y - second_sprite.y), 2) < math.pow((player.image:getHeight()/2), 2)) then
                return true
            end
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
