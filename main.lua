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
    -- local _, _, flags = love.window.getMode()
    -- local width, height = love.window.getDesktopDimensions(flags.display)
    love.window.setMode(600, 600)

    background = {image = love.graphics.newImage("sprites/background.jpg"),
        x = 0,
        y = 0
    }

    player = {image = love.graphics.newImage("sprites/spaceship.png"),
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() / 2,
        speed = 5,
        alive = true
    }

    player_lasers = {}
    ufo_lasers = {}
    ufos = {}
    ufo_time = 0
    player_score = 0
    ufo_counter = 0 -- this is the best I can come up with for now
    story_text = ""

    start = love.timer.getTime()
end

function love.mousereleased(x, y, button)
    -- Create a laser
    -- TODO: Don't allow player to create laser on every click (make them wait some milliseconds)
    if player.alive then
        player_lasers[#player_lasers + 1] = {image = love.graphics.newImage("sprites/laser.jpg"),
            x = player.x,
            y = player.y,
            dx = math.cos(player.rotation - PLAYER_IMG_ROTATION_CF),
            dy = math.sin(player.rotation - PLAYER_IMG_ROTATION_CF)
        }
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
end

function love.update(dt)
    update.background()
    update.player()
    update.player_projectiles()
    update.trigger_timed_events()
    update.ufo(dt)
    update.ufo_projectiles()
end

function love.draw()
    draw.background()
    draw.player()
    draw.projectile()
    draw.ufos()
    draw.ufo_projectiles()
    draw.text()
end
