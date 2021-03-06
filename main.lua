-- A little side scrolling shooter

-- TODO / ideas
-- RPG stages
-- obstacles / asteroids
-- sprites
--

-- circle I: ghosts that can become translucent
-- circle II: giant tail monster defining which circle to go to?
-- tough winds

utils = require("utils")
update = require("update")
draw = require("draw")

SPACE_BACKGROUND = love.graphics.newImage("sprites/background.jpg")
SHIP_BACKGROUND = love.graphics.newImage("sprites/mothership.jpg")

SHIP_PLAYER = love.graphics.newImage("sprites/spaceship.png")
CHARACTER_PLAYER = love.graphics.newImage("sprites/dante.png")

MAIN_THEME = love.audio.newSource( "music/Soft_and_Furious_-_09_-_Horizon_Ending.mp3", "static")

STORY_TEXTS = {[1] = "",
    [2] = "Lost. Hopelessly lost...",
    [3] = "I don't know how long it's been but I'm running low on fuel and food.",
    [4] = "My name is Dante."
}

function love.load()
    -- Initial setup
    -- get screen dimensions for setting window size
    local _, _, flags = love.window.getMode()
    desktop_width, desktop_height = love.window.getDesktopDimensions(flags.display)

    utils.set_window()
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
        alive = true,
        rotation = 0
    }

    love.audio.play(MAIN_THEME)
    music_start_time = love.timer.getTime()

    restart_game()
end

function restart_game()
    -- Runs when the game launches and when the game restarts after a game over
    level = 0
    love.mouse.setRelativeMode( false )
    player.x = window_width / 2
    player.y = window_height / 2
    menu_selection = 1
    player_lasers = {}
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
    start_action = 0
    ufo_destroyed = 99999
    level_over = false
    rotation_y = love.mouse.getY()
    melee_active = 0
    options_menu = false
    volume = 100

    player.ammo = 3

    -- might want to move these
    cam = {x = -5,
        y = -5
    }

    continue_story = true
    start = love.timer.getTime()
end

function love.mousereleased(x, y, button)
    -- Should this be mousepressed?
    _select()
end

function love.mousemoved( x, y, dx, dy )
    rotation_y = rotation_y + dy

    now = love.timer.getTime()

    if dy > 25 and now > melee_active + 2 then
        melee_active = now
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
                if utils.overlap(npc, player) then
                    continue_story = true
                    start_action = 0
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
        _select()
    end

    if key == "escape" and player.alive then
        -- level 100 is 'pause' state
        if level ~= 100 then
            unpause_level = level
            unpause_start_action = start_action
            level = 100
            start_action = 0

            love.mouse.setRelativeMode( false )

        elseif level == 100 and start_action == 0 then
            level = unpause_level
            start_action = unpause_start_action
        end
    end
end

function _select()
    -- Create a laser if player is alive
    if start_action == 0 or level == 100 then
        update.select_menu_item()

    elseif player.alive and
        start_action > 0 and
        (#player_lasers == 0 or
            utils.time_check(player_lasers[#player_lasers].create_time, 0.3)) then
                -- If there are already player_lasers then wait some milliseconds before creating another
                update.create_player_projectile()
    end

    if player.alive == false then
        restart_game()
    end

    if #type_writer_c < #story_text then
        type_writer_c = story_text
    end
end

function love.update(dt)
    update.music()
    if level == 0 or level == 100 then
        update.menu()
    else
        update.background()
        update.obstacle()
        update.player()

        if level == 1 and level_over == true then
            -- action level stuff
            ufos = {}
            love.graphics.clear()
            level = level + 1
            level_over = false

            player.x = window_width / 2
            player.y = window_height / 2
            background.x = 0
            background.y = 0

            -- Might need to rename this, can't continue story unless this if false
            start_action = 0
        elseif level == 1 then
            update.projectiles(player_lasers, dt)
            update.ufo(dt)
            update.projectiles(ufo_lasers, dt)
            update.melee_attack()
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
        -- for testing the hitbox
        -- draw.player_hitbox()
        draw.ufos()
        if level == 1 then
            draw.projectile()
            draw.crosshair()
            draw.ufo_projectiles()
            draw.weapons()
        end

        draw.npcs()
        draw.text()
        draw.title_card()
    else
        draw.game_over_text()
    end

    if level == 2 then
        love.graphics.pop()
    end
end
