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

    level = 0
    menu_selection = 1

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
    ufo_counter = 0
    story_text = ""
    start_action = false
    continue_story = true

    start = love.timer.getTime()
end

function love.mousereleased(x, y, button)
    --TODO: Make this work for the main menu
    -- Create a laser if player is alive
    if level ~= 0 and player.alive then
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
    if key == "space" or key == "return" or key == "kpenter" then
        --TODO: basically the mouse should be able to do all of this too
        -- AKA make this a function that both mouse and these keys call
        if start_action == false then
            if continue_story == true then
                -- Handle main menu selection
                if menu_selection == 1 then
                    level = 1
                elseif menu_selection == 2 then
                    -- TODO: add settings and options
                    print('options')
                elseif menu_selection == 3 then
                    love.event.quit()
                end
            elseif continue_story == false then
                -- remove story text on enter or space
                continue_story = true
            end
        end

        if player.alive == false then
            -- Handle game over screen (navigate back to main menu)
            level = 0
            player.alive = true
        end
    end
end

function love.update(dt)
    if level == 0 then
        update.main_menu()
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
        draw.main_menu()
    elseif player.alive then
        draw.player()
        draw.projectile()
        draw.ufos()
        draw.ufo_projectiles()
        draw.text()
    else
        --TODO: Make this navigate back to main menu
        draw.game_over_text()
    end
end
