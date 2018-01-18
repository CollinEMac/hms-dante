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

    restart_game()
end

--TODO: Create pause menu

function restart_game()
    -- Runs when the game launches and when the game restarts after a game over
    level = 0
    menu_selection = 1
    player_lasers = {}
    last_player_laser_create = 0
    ufo_lasers = {}
    ufos = {}
    ufo_time = 0
    player_score = 0
    ufo_counter = 0
    story_text = ""
    start_action = false
    continue_story = true

    start = love.timer.getTime()
end

function love.mousereleased(x, y, button)
    -- Create a laser if player is alive
    if start_action == false then
        update.select_menu_item()
    end

    if level ~= 0 and player.alive and start_action == true and (love.timer.getTime() > last_player_laser_create + 0.3 ) then
        -- If there are already player_lasers then wait some milliseconds before creating another
        update.create_player_projectiles()
    end

    if player_alive == false then
        restart_game()
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
    if key == "space" or key == "return" or key == "kpenter" then
        update.select_menu_item()
        if player_alive == false then
            restart_game()
        end
    end
    if key == "escape" then
        -- level 100 is 'pause' state
        level = 100
    end
end

function love.update(dt)
    if level == 0 or level == 100 then
    -- if level == 0 then
        update.menu()
    else
        update.background()
        update.player()
        update.player_projectiles()
        update.ufo(dt)
        update.ufo_projectiles()
        update.story()
    end
end

function love.draw()
    draw.background()
    if level == 0 then
        draw.menu('main')
    elseif level == 100 then
        draw.menu('pause')
    elseif player.alive then
        draw.player()
        draw.projectile()
        draw.ufos()
        draw.ufo_projectiles()
        draw.text()
    else
        draw.game_over_text()
    end
end
