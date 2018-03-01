-- Simple functions and tedious calculations

local utils={}

function utils.get_player_rotation()
    -- returns the players rotation in radians
    player.rotation = math.atan2((mouse_y - player.y), (mouse_x - player.x)) + PLAYER_IMG_ROTATION_CF
end

function utils.round(num, numDecimalPlaces)
    -- round num to defined number of places
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function utils.overlap(first_sprite, second_sprite, first_CF, second_CF)
    -- checks to see if two sprites are overlapping each other
    -- TODO: CHECK THIS, I THINK IT'S FUCKED UP
    if first_sprite.x + (first_CF * first_sprite.image:getWidth()/2) > (second_sprite.x - (second_CF * second_sprite.image:getWidth()/2)) and
        first_sprite.x - (first_CF * first_sprite.image:getWidth()/2) < (second_sprite.x + (second_CF * second_sprite.image:getWidth())) and
        first_sprite.y + (first_CF * first_sprite.image:getWidth()/2)  > (second_sprite.y - (second_CF * second_sprite.image:getHeight()/2)) and
        first_sprite.y - (first_CF * first_sprite.image:getWidth()/2) < (second_sprite.y + (second_CF * second_sprite.image:getHeight())) then
            return true
    end

    return false
end

return utils
