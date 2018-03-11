-- A little side scrolling shooter

--
-- TODO / ideas
-- RPG stages
-- obstacles / asteroids
-- options menu
-- sprites
-- Death animations
--

-- Design notes
-- I'm thinking about maybe not doing this whole "rpg stage" things
-- and instead just doing a visual novel type of approach where
-- discussion happens and the player is always in the ship
-- On the other hand, the rpg hub section will probably do a lot to
-- make the game feel bigger. Either way I need to focus on gameplay
-- for now

-- circle I: ghosts that can become translucent?
-- circle II: giant tail monster defining which circle to go to?
-- tough winds

utils = require("utils")
update = require("update")
draw = require("draw")

-- Correction for the image, it's tilted to the side
PLAYER_IMG_ROTATION_CF = 0.75 * math.pi
UFO_SIZE_CF = 0.10
PLAYER_PROJECTILE_SIZE_CF = 0.085
ENEMY_PROJECTILE_SIZE_CF = 0.05

SPACE_BACKGROUND = love.graphics.newImage("sprites/background.jpg")
SHIP_BACKGROUND = love.graphics.newImage("sprites/brown.jpg")

SHIP_PLAYER = love.graphics.newImage("sprites/spaceship.png")
CHARACTER_PLAYER = love.graphics.newImage("sprites/dante.jpg")

STORY_TEXTS = {[1] = "",
    [2] = "Lost. Hopelessly lost...",
    [3] = "I don't know how long it's been but I'm running low on fuel and food.",
    [4] = "My name is Dante."
}

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

function love.load()
    -- Initial setup
    -- get screen dimensions for setting window size
    local _, _, flags = love.window.getMode()
    local desktop_width, desktop_height = love.window.getDesktopDimensions(flags.display)

    window_width = desktop_width / 3
    window_height = window_width

    love.window.setMode(window_width, window_height)
    love.window.setTitle('Starship Dante')

    background = {image = SPACE_BACKGROUND,
        x = 0,
        y = 0
    }

    player = {image = SHIP_PLAYER,
        name = 'Dante',
        x = window_width / 2,
        y = window_height / 2,
        speed = 5,
        weapon = '',
        weapon_time = love.timer.getTime(),
        alive = true
    }

    restart_game()
end

function restart_game()
    -- Runs when the game launches and when the game restarts after a game over
    level = 0
    player.x = window_width / 2
    player.y = window_height / 2
    menu_selection = 1
    player_lasers = {}
    last_player_laser_create = 0
    ufo_lasers = {}
    ufos = {}
    weapons = {}
    incoming_obstacles = {}
    player_score = 0
    ufo_counter = 0
    npcs = {}
    character = 'narrator'
    story_text = STORY_TEXTS[1]
    type_writer_c = ""
    type_writer_time = 0
    start_action = false
    ufo_destroyed = 99999

    -- might want to move these
    cam = {x = -5,
        y = -5
    }

    continue_story = true
    start = love.timer.getTime()
end

function love.mousereleased(x, y, button)
    -- Create a laser if player is alive
    if start_action == false or level == 100 then
        update.select_menu_item()

    elseif player.alive and start_action == true and
        (love.timer.getTime() > last_player_laser_create + 0.3) then
            -- If there are already player_lasers then wait some milliseconds before creating another
            update.create_player_projectiles()
    end

    if player.alive == false then
        restart_game()
    end

    if #type_writer_c < #story_text then
        type_writer_c = story_text
    end
end

function love.keypressed(key)
    -- adjust player speed
    if key == "e" then
        if level == 1 and player.speed < 8 then
            player.speed = player.speed + 1
        elseif level == 2 then
            for i, npc in ipairs(npcs) do
            -- if player on npc, interact with them
                if utils.overlap(npc, player, PLAYER_PROJECTILE_SIZE_CF) then
                    continue_story = true
                    start_action = false
                    speaking_char = npc
                end
            end
        end
    end

    if key == "q" then
        if level == 1 and player.speed > 2 then
            player.speed = player.speed - 1
        end
    end

    if key == "space" or key == "return" or key == "kpenter" then
        update.select_menu_item()
        if player.alive == false then
            restart_game()
        end

        if #type_writer_c < #story_text then
            type_writer_c = story_text
        end
    end

    if key == "escape" and player.alive then
        -- level 100 is 'pause' state
        if level ~= 100 then
            unpause_level = level
            unpause_start_action = start_action
            level = 100
            start_action = false
        elseif level == 100 and start_action == false then
            level = unpause_level
            start_action = unpause_start_action
        end
    end
end

function love.update(dt)
    if level == 0 or level == 100 then
        update.menu()
    else
        update.background()
        update.obstacle()
        update.player()

        if level == 1 and ufo_counter == 3 and #ufos == 0 then
            -- action level stuff
            ufos = {}
            -- ufo_projectiles = {}
            -- player_projectiles = {}
            love.graphics.clear()
            level = level + 1

            player.x = window_width / 2
            player.y = window_height / 2
            background.image = SHIP_BACKGROUND
            background.x = 0
            background.y = 0

            -- Might need to rename this, can't continue story unless this if false
            start_action = false
        elseif level == 1 then
            update.projectiles(player_lasers, dt)
            update.ufo(dt)
            update.projectiles(ufo_lasers, dt)
            update.weapons(dt)
            update.story(player)
        elseif level == 2 then
            update.npcs()
            update.story(speaking_char)
        end
    end
end

function love.draw()

    if level == 2 then
        love.graphics.push()
        love.graphics.translate(cam.x, cam.y)
    end

    draw.background()

    if level == 0 then
        draw.menu('main')
    elseif level == 100 then
        draw.menu('pause')
    elseif player.alive then
        draw.obstacles()
        draw.player()
        draw.ufos()
        if level == 1 then
            draw.projectile()
            draw.ufo_projectiles()
            draw.weapons()
        end

        draw.npcs()
        draw.text()
    else
        draw.game_over_text()
    end

    if level == 2 then
        love.graphics.pop()
    end
end
