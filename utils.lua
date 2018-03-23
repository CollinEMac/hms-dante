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
    -- checks to see if two sprites are overlapping each other
    if first_sprite.x + (first_sprite.image:getWidth()/2) > (second_sprite.x - (second_sprite.image:getWidth()/2)) and
        first_sprite.x - (first_sprite.image:getWidth()/2) < (second_sprite.x + (second_sprite.image:getWidth()/2)) and
        first_sprite.y + (first_sprite.image:getHeight()/2)  > (second_sprite.y - (second_sprite.image:getHeight()/2)) and
        first_sprite.y - (first_sprite.image:getHeight()/2) < (second_sprite.y + (second_sprite.image:getHeight()/2)) then
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
