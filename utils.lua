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

return utils
