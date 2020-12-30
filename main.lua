Class = require 'class'
push = require 'push'

require 'Animation'
require 'Map'
require 'Player'
require 'Player2'

-- close resolution to NES but 16:9
VIRTUAL_WIDTH = 216
VIRTUAL_HEIGHT = 121

-- actual window resolution
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- seed RNG
math.randomseed(os.time())

-- makes upscaling look pixel-y instead of blurry
love.graphics.setDefaultFilter('nearest', 'nearest')

-- an object to contain our map data
map = Map()

-- performs initialization of all objects and data needed by program
function love.load()

    -- sets up a different, better-looking retro font as our default
    smallFont = love.graphics.newFont('fonts/font.ttf', 8)
    bigFont = love.graphics.newFont('fonts/font.ttf', 16)

    -- sets up virtual screen resolution for an authentic retro feel
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true
    })

    love.window.setTitle('Concentration Commandos')

    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}

    --initialize other variables
    p1score = 0
    p2score = 0

    roundWinner = 0

    gameState = 'title'
end

-- called whenever window is resized
function love.resize(w, h)
    push:resize(w, h)
end

-- global key pressed function
function love.keyboard.wasPressed(key)
    if (love.keyboard.keysPressed[key]) then
        return true
    else
        return false
    end
end

-- global key released function
function love.keyboard.wasReleased(key)
    if (love.keyboard.keysReleased[key]) then
        return true
    else
        return false
    end
end

-- called whenever a key is pressed
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
    -- change gamestate 
    if key == 'enter' or key == 'return' then
        if gameState == 'title' then
            gameState = 'select'
        elseif gameState == 'select' then
            gameState = 'ready'
        elseif gameState == 'ready' then
            gameState = 'play'
        elseif gameState == 'victory' then
            gameState = 'select'
            p1score = 0
            p2score = 0
        elseif gameState == 'ready' then
            gameState = 'play'
        end
    end
    love.keyboard.keysPressed[key] = true
end

-- called whenever a key is released
function love.keyreleased(key)
    love.keyboard.keysReleased[key] = true
end

-- called every frame, with dt passed in as delta in time since last frame
function love.update(dt)
    map:update(dt)

    -- reset all keys pressed and released this frame
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
    
end

-- called each frame, used to render to the screen
function love.draw()
    -- begin virtual resolution drawing
    push:apply('start')

    --draw title screen
    if gameState == 'title' then
        love.graphics.setFont(bigFont)
        love.graphics.clear(0/255, 0/255, 0/255, 255/255)
        love.graphics.print("Welcome To", 60, 5)
        love.graphics.print("CONCENTRATION COMMANDOS", 0, 22)
        love.graphics.print("Press Enter to Start", 20, 39)

        love.graphics.print("Controls", 0, 55)
        love.graphics.print("P1", 100, 55)
        love.graphics.print("P2", 150, 55)

        love.graphics.setFont(smallFont)

        love.graphics.print("Move", 0, 70)
        love.graphics.print("Jump", 0, 80)
        love.graphics.print("Block", 0, 90)
        love.graphics.print("Attack", 0, 100)
        love.graphics.print("Special", 0, 110)

        love.graphics.print("A/D", 100, 70)
        love.graphics.print("W", 100, 80)
        love.graphics.print("S", 100, 90)
        love.graphics.print("F", 100, 100)
        love.graphics.print("G", 100, 110)

        love.graphics.print("Left/Right", 150, 70)
        love.graphics.print("Up", 150, 80)
        love.graphics.print("Down", 150, 90)
        love.graphics.print("K", 150, 100)
        love.graphics.print("L", 150, 110)


    -- character select and title screen
    elseif gameState == 'select' then
        love.graphics.setFont(smallFont)
        love.graphics.clear(0/255, 0/255, 0/255, 255/255)
        love.graphics.print("Choose Your Fighter! Press Enter To Start!", 15, 10)
        map:render()
        love.graphics.setFont(bigFont)
    else
    -- clear screen using Mario background blue
        love.graphics.clear(108/255, 140/255, 255/255, 255/255)

        -- renders our map object onto the screen
        map:render()
        

        -- state label
        if gameState == 'ready' then
            love.graphics.print("Press Enter To Start!", 18, VIRTUAL_HEIGHT / 6)
            if (p1score + p2score) > 0 then
                love.graphics.setFont(smallFont)
                love.graphics.print('Player ' .. roundWinner .. ' Won Round '.. p1score + p2score, 64, VIRTUAL_HEIGHT / 3)
                love.graphics.setFont(bigFont)
            end 
        elseif gameState == 'play' then
            love.graphics.print("Fight!", 85, VIRTUAL_HEIGHT / 6)
        elseif gameState == 'victory' then
            if p1score > p2score then
                love.graphics.print("Player 1 wins!", 50, VIRTUAL_HEIGHT / 6)
                love.graphics.setFont(smallFont)
                love.graphics.print("Press Enter For Character Select", 38, VIRTUAL_HEIGHT / 3)
                love.graphics.setFont(bigFont)
            else
                love.graphics.print("Player 2 wins!", 50, VIRTUAL_HEIGHT / 6)
                love.graphics.setFont(smallFont)
                love.graphics.print("Press Enter For Character Select", 38, VIRTUAL_HEIGHT / 3)
                love.graphics.setFont(bigFont)
            end
        end
    

        -- scoreboard
        love.graphics.print('P1: '.. tostring(p1score), VIRTUAL_WIDTH / 2 - 50, 5)
        love.graphics.print('P2: '.. tostring(p2score), VIRTUAL_WIDTH / 2 + 10, 5)    
    end

    -- end virtual resolution
    push:apply('end')


end
