-- GLSL shaders
-- http://blogs.love2d.org/content/beginners-guide-shaders

shaders = {}

--This is an obstacle warning
red_shader = love.graphics.newShader[[
    // Red shader code, makes screen red between y_min and y_max

    extern number y_min;
    extern number y_max;

    vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
        vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
        if (texture_coords.y > y_min && texture_coords.y < y_max) {
            pixel.r = pixel.r + 0.60;
        }
        return pixel;
    }
]]

-- Add this to ufos when they die
death_shader = love.graphics.newShader[[
    // Red shader code, makes screen red between y_min and y_max

    extern float saturation;

    vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
        vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
        pixel.r = pixel.r + saturation;
        return pixel;
    }
]]

-- Adjust trasnparency
fade_shader = love.graphics.newShader[[
    // Red shader code, makes screen red between y_min and y_max

    extern float saturation;

    vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
        vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
        pixel.a = pixel.a - saturation;
        return pixel;
    }
]]
