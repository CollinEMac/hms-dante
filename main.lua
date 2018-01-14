-- A little side scrolling shooter

utils = require("utils")
update = require("update")
draw = require("draw")

-- Correction for the image, it's tilted to the side
PLAYER_IMG_ROTATION_CF = 0.75 * math.pi
UFO_SIZE_CF = 0.15
PROJECTILE_SIZE_CF = 0.1
PLAYER_PROJECTILE_SPEED = 7

function love.load()
    -- Initial setup

    -- get screen dimensions for setting window size
    local _, _, flags = love.window.getMode()
    local desktop_width, desktop_height = love.window.getDesktopDimensions(flags.display)

    -- TODO: perhaps images should be stretched by the ratio of window to screen
    window_width = desktop_width / 3
    window_height = window_width

    love.window.setMode(window_width, window_height)
    love.window.setTitle('Starship Dante')

    background = {image = love.graphics.newImage("sprites/background.jpg"),
        x = 0,
        y = 0
    }

    player = {image = love.graphics.newImage("sprites/spaceship.png"),
        x = window_width / 2,
        y = window_height / 2,
        speed = 5,
        alive = true
    }

    player_lasers = {}
    last_player_laser_create = 0
    ufo_lasers = {}
    ufos = {}
    ufo_time = 0
    player_score = 0
    ufo_counter = 0 -- this is the best I can come up with for now
    story_text = ""
    start_action = false
    continue_story = true

    start = love.timer.getTime()
end

function love.mousereleased(x, y, button)
    -- Create a laser if player is alive
    if player.alive then
        -- If there are already player_lasers then wait some milliseconds before creating another
        if #player_lasers == 0 or (love.timer.getTime() > last_player_laser_create + 0.3) then
            update.create_player_projectiles()
        end
    end
end

function love.keypressed(key)
    -- adjust player speed
    if key == "e" and player.speed < 8 then
        player.speed = player.speed + 1
    end
    if key == "q" and player.speed > 2 then
        player.speed = player.speed - 1
    end
    if key == "space" or key == "return" or key == "kpenter" and continue_story == false and start_action == false then
        -- remove story text on enter or space
        continue_story = true
    end
end

function love.update(dt)
    update.background()
    update.player()
    update.player_projectiles()
    update.ufo(dt)
    update.ufo_projectiles()
    update.story()
end

function love.draw()
    if player.alive then
        draw.background()
        draw.player()
        draw.projectile()
        draw.ufos()
        draw.ufo_projectiles()
        draw.text()
    else
        draw.game_over_text()
    end
end
