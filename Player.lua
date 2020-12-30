--[[
    Represents our player in the game, with its own sprite.
]]

Player = Class{}

local WALKING_SPEED = 140
local JUMP_VELOCITY = 400

function Player:init(map)
    --character color/ability identifier
    self.skin = 1

    --state for calculating basic attack and cooldown
    self.playerState = 'neutral'
    self.count = 200

    --position
    self.x = 0
    self.y = 0
    self.width = 16
    self.height = 20


    -- offset from top left to center to support sprite flipping
    self.xOffset = 8
    self.yOffset = 10

    -- reference to map for checking tiles
    self.map = map
    self.texture = love.graphics.newImage('graphics/blue_alien.png')

    -- special animations
    -- snake
    self.snakeImg = love.graphics.newImage('graphics/snake.png')
    self.snakerevImg = love.graphics.newImage('graphics/snakerev.png')
    self.snakesright = {}
    self.snakesleft = {}
    self.snakeCanShoot = true
    self.snakeCanShootTimerMax = 2
    self.snakeCanShootTimer = self.snakeCanShootTimerMax

    --bullet
    self.bulletImg = love.graphics.newImage('graphics/bullet.png')
    self.bulletsright = {}
    self.bulletsleft = {}
    self.bulCanShoot = true
    self.bulCanShootTimerMax = 0.2
    self.bulCanShootTimer = self.bulCanShootTimerMax

    --book
    self.bookImg = love.graphics.newImage('graphics/book.png')
    self.booksright = {}
    self.booksleft = {}
    
    self.cycle = 0.8
    self.cycle1 = 0.8
    self.traj= -300
    
    self.canShoot = true
    self.canShootTimerMax = 1
    self.canShootTimer = self.canShootTimerMax

    self.canShoot1 = true
    self.canShootTimerMax1 = 1
    self.canShootTimer1 = self.canShootTimerMax1
    
    --dash
    self.dashCount = 50
    self.dashing = false
    self.dashTimer = 0
    
    -- sound effects
    self.sounds = {
        ['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
        ['snake'] = love.audio.newSource('sounds/snake.wav', 'static'),
        ['book'] = love.audio.newSource('sounds/book.wav', 'static'),
        ['bullet'] = love.audio.newSource('sounds/bullet.wav', 'static'),
        ['kick'] = love.audio.newSource('sounds/kick.wav', 'static'),
        ['dash'] = love.audio.newSource('sounds/dash.wav', 'static'),
    }

    -- animation frames
    self.frames = {}

    -- current animation frame
    self.currentFrame = nil

    -- used to determine behavior and animations
    self.state = 'idle'

    -- determines sprite flipping
    self.direction = 'left'

    -- x and y velocity
    self.dx = 0
    self.dy = 0

    -- position on top of map tiles
    self.y = map.tileHeight * ((map.mapHeight) / 4) - self.height - 16
    self.x = map.tileWidth * 10 - self.width - 100

    -- initialize all player animations
    self.animations = {
        ['idle'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(0, 0, 16, 20, self.texture:getDimensions())
            }
        }),
        ['walking'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(128, 0, 16, 20, self.texture:getDimensions()),
                love.graphics.newQuad(144, 0, 16, 20, self.texture:getDimensions()),
                love.graphics.newQuad(160, 0, 16, 20, self.texture:getDimensions()),
                love.graphics.newQuad(144, 0, 16, 20, self.texture:getDimensions()),
            },
            interval = 0.15
        }),
        ['jumping'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(32, 0, 16, 20, self.texture:getDimensions())
            }
        }),
        ['crouching'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(48, 0, 16, 20, self.texture:getDimensions())
            }
        }),
        ['kicking'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(96, 0, 16, 20, self.texture:getDimensions())
            }
        })
    }

    -- initialize animation and current frame we should render
    self.animation = self.animations['idle']
    self.currentFrame = self.animation:getCurrentFrame()

    -- behavior map we can call based on player state
    self.behaviors = {
        ['idle'] = function(dt)
            
            if love.keyboard.wasPressed('w') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['jumping']
                self.sounds['jump']:play()
                self.playerState = 'neutral'
            elseif love.keyboard.isDown('a') then
                self.direction = 'left'
                self.dx = -WALKING_SPEED
                self.state = 'walking'
                self.animations['walking']:restart()
                self.animation = self.animations['walking']
                self.playerState = 'neutral'
            elseif love.keyboard.isDown('d') then
                self.direction = 'right'
                self.dx = WALKING_SPEED
                self.state = 'walking'
                self.animations['walking']:restart()
                self.animation = self.animations['walking']
                self.playerState = 'neutral'
            elseif love.keyboard.isDown('s') then
                self.state = 'crouching'
                self.animation = self.animations['crouching']
                self.dx = 0
                self.playerState = 'block'
            elseif love.keyboard.isDown('f') and self.count >= 50 then
                self.sounds['kick']:play()
                self.animation = self.animations['kicking']
                self.count = 0
                self.playerState = 'attack'
            else
                self.dx = 0
            end
        end,
        ['walking'] = function(dt)
            
            -- keep track of input to switch movement while walking, or reset
            -- to idle if we're not moving
            if love.keyboard.wasPressed('w') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['jumping']
                self.sounds['jump']:play()
                self.playerState = 'neutral'
            elseif love.keyboard.isDown('a') then
                self.direction = 'left'
                self.dx = -WALKING_SPEED
                self.playerState = 'neutral'
            elseif love.keyboard.isDown('d') then
                self.direction = 'right'
                self.dx = WALKING_SPEED
                self.playerState = 'neutral'
            elseif love.keyboard.isDown('s') then
                self.state = 'crouching'
                self.animation = self.animations['crouching']
                self.dx = 0
                self.playerState = 'block'
            elseif love.keyboard.isDown('f') and self.count >= 50 then
                self.sounds['kick']:play()
                self.animation = self.animations['kicking']
                self.count = 0
                self.playerState = 'attack'
            else
                self.dx = 0
                self.state = 'idle'
                self.animation = self.animations['idle']
            end

            -- check for collisions moving left and right
            self:checkRightCollision()
            self:checkLeftCollision()

            -- check if there's a tile directly beneath us
            if not self.map:collides(self.map:tileAt(self.x, self.y + self.height)) and
                not self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then
                
                -- if so, reset velocity and position and change state
                self.state = 'jumping'
                self.animation = self.animations['jumping']
                self.playerState = 'neutral'
            end
        end,
        ['jumping'] = function(dt)
            if love.keyboard.isDown('k') and self.count >= 50 then
                self.sounds['kick']:play()
                self.animation = self.animations['kicking']
                self.count = 0
                self.playerState = 'attack'
            end

            -- break if we go below the surface
            if self.y > 300 then
                return
            end

            if love.keyboard.isDown('a') then
                self.direction = 'left'
                self.dx = -WALKING_SPEED
                self.playerState = 'neutral'
            elseif love.keyboard.isDown('d') then
                self.direction = 'right'
                self.dx = WALKING_SPEED
                self.playerState = 'neutral'
            end

            -- apply map's gravity before y velocity
            self.dy = self.dy + self.map.gravity

            -- check if there's a tile directly beneath us
            if self.map:collides(self.map:tileAt(self.x, self.y + self.height)) or
                self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then
                
                -- if so, reset velocity and position and change state
                self.dy = 0
                self.state = 'idle'
                self.animation = self.animations['idle']
                self.y = (self.map:tileAt(self.x, self.y + self.height).y - 1) * self.map.tileHeight - self.height
                self.playerState = 'neutral'
            end

            -- check for collisions moving left and right
            self:checkRightCollision()
            self:checkLeftCollision()
        end,
        --crouching state immune to special moves
        ['crouching'] = function(dt)
            self.dx = 0
            self.state = 'idle'
            self.playerState = 'block'
        end
    }
end

function Player:update(dt)
    --character selection
    if gameState == 'select' then 
        if love.keyboard.wasPressed('w') then
            self.skin = 1
        elseif love.keyboard.wasPressed('d') then
            self.skin = 2
        elseif love.keyboard.wasPressed('a') then
            self.skin = 3
        elseif love.keyboard.wasPressed('s') then
            self.skin = 4
        end

    else
        if self.skin == 1 then
            self.texture = love.graphics.newImage('graphics/blue_alien.png')
        elseif self.skin == 2 then
            self.texture = love.graphics.newImage('graphics/red_alien.png')
        elseif self.skin == 3 then
            self.texture = love.graphics.newImage('graphics/pink_alien.png')
        elseif self.skin == 4 then
            self.texture = love.graphics.newImage('graphics/green_alien.png')
        end
    end

    --kick cooldown count
    self.count = self.count + 1

    --movement calculation only in play state
    if gameState == 'play' then 
        self.behaviors[self.state](dt)
        self.animation:update(dt)
        self.currentFrame = self.animation:getCurrentFrame()
        --faster movement for dash
        if self.dashing == false then
            self.x = self.x + self.dx * dt
        else
            self.x = self.x + self.dx * dt + 5 * self.scaleX
        end

        -- apply velocity
        self.y = self.y + self.dy * dt

        self.x = math.max(0, self.x)
        self.x = math.min(self.x, VIRTUAL_WIDTH - self.width)
    end

    if self.y > map.tileHeight * ((map.mapHeight) / 4) - self.height - 16 then
        self.y = map.tileHeight * ((map.mapHeight) / 4) - self.height - 16
    end

    -- snakes
    self.snakeCanShootTimer = self.snakeCanShootTimer - (1*dt)
    if self.snakeCanShootTimer < 0 then 
        self.snakeCanShoot = true
    end

    if self.skin == 4 and gameState == 'play' then
        if love.keyboard.isDown('g') and self.snakeCanShoot and self.scaleX == 1 then 
            self.newSnake = {x = self.x + self.width, y = self.y, img = self.snakeImg}
            table.insert(self.snakesright, self.newSnake)
            self.snakeCanShoot = false
            self.snakeCanShootTimer = self.snakeCanShootTimerMax
            self.sounds['snake']:play()
        end

        if love.keyboard.isDown('g') and self.snakeCanShoot and self.scaleX == -1 then 
            self.newSnake1 = {x = self.x - self.width, y = self.y, img = self.snakerevImg}
            table.insert(self.snakesleft, self.newSnake1)
            self.snakeCanShoot = false
            self.snakeCanShootTimer = self.snakeCanShootTimerMax
            self.sounds['snake']:play()
        end
        
        for i, snake in ipairs(self.snakesright) do 
            snake.x = self.x + self.width
            snake.y = self.y
            if self.snakeCanShootTimer < 1.3 then
                table.remove(self.snakesright, i)
            end
        end
        
        for i, snake in ipairs(self.snakesleft) do 
            snake.x = self.x - self.width - 5
            snake.y = self.y
            if self.snakeCanShootTimer < 1.3 then
                table.remove(self.snakesleft, i)
            end
        end
    end

    --bullets
    self.bulCanShootTimer = self.bulCanShootTimer - (.1*dt)
    if self.bulCanShootTimer < 0 then 
        self.bulCanShoot = true
    end

    if self.skin == 1 and gameState == 'play' then
        if love.keyboard.isDown('g') and self.bulCanShoot and self.scaleX == 1 then 
            self.newBullet = {x = self.x + (self.width / 2) + 4, y = self.y + 5, img = self.bulletImg}
            table.insert(self.bulletsright, self.newBullet)
            self.bulCanShoot = false
            self.bulCanShootTimer = self.bulCanShootTimerMax
            self.sounds['bullet']:play()
        end

        if love.keyboard.isDown('g') and self.bulCanShoot and self.scaleX == -1 then 
            self.newBullet1 = {x = self.x - 20, y = self.y + 5, img = self.bulletImg}
            table.insert(self.bulletsleft, self.newBullet1)
            self.bulCanShoot = false
            self.bulCanShootTimer = self.bulCanShootTimerMax
            self.sounds['bullet']:play()
        end
        
        for i, bullet in ipairs(self.bulletsright) do 
            bullet.x = bullet.x + (100*dt)

            if bullet.x > VIRTUAL_WIDTH then
                table.remove(self.bulletsright, i)
            end
        end
        
        for i, bullet in ipairs(self.bulletsleft) do 
            bullet.x = bullet.x - (100 * dt)

            if bullet.x < -30 then    
                table.remove(self.bulletsleft, i)
            end
        end
    end    

    --books
    self.canShootTimer = self.canShootTimer - (1*dt)
    if self.canShootTimer < 0 then 
        self.canShoot = true
    end

    self.canShootTimer1 = self.canShootTimer1 - (1*dt)
    if self.canShootTimer1 < 0 then 
        self.canShoot1 = true
    end

    if self.skin == 2 and gameState == 'play' then
        if love.keyboard.isDown('g') and self.canShoot and self.scaleX == 1 then 
            self.newBook = {x = self.x + (self.width / 2), y = self.y, dx = 0, dy = 0, img = self.bookImg}
            table.insert(self.booksright, self.newBook)
            self.canShoot = false
            self.canShootTimer = self.canShootTimerMax
            self.cycle = 1
            self.sounds['book']:play()
        end

        if love.keyboard.isDown('g') and self.canShoot and self.scaleX == -1 then 
            self.newBook = {x = self.x + (self.width / 2) - 8, y = self.y, dx = 0, dy = 0, img = self.bookImg}
            table.insert(self.booksleft, self.newBook)
            self.canShoot = false
            self.canShootTimer = self.canShootTimerMax
            self.cycle1 = 1
            self.sounds['book']:play()
        end
        
        for i, book in ipairs(self.booksleft) do 
            book.dy = book.dy + 1000*dt + self.traj * self.cycle1
            book.dx = -150
            book.x = book.x + dt*book.dx
            book.y = book.y + dt*book.dy
            if book.y > VIRTUAL_HEIGHT then 
                table.remove(self.booksleft, i)
            end
            self.cycle1 = 0
            if self.canShootTimerMax1 < 0 then
                self.cycle1 = 1
            end
        end

        for i, book in ipairs(self.booksright) do 
            book.dy = book.dy + 1000*dt + self.traj * self.cycle
            book.dx = 150
            book.x = book.x + dt*book.dx
            book.y = book.y + dt*book.dy
            if book.y > VIRTUAL_HEIGHT then 
                table.remove(self.booksright, i)
            end
            self.cycle = 0
            if self.canShootTimer < 0 then
                self.cycle = 1
            end
        end
    end

    --dash
    if self.skin == 3 and gameState == 'play' then
        if love.keyboard.isDown('g') and self.dashCount > 50 then 
            self.sounds['dash']:play()
            self.dashCount = 0
            self.dashTimer = 0
            self.dashing = true
        end
    end
    if self.dashTimer > 9 then
        self.dashing = false
    end
    self.dashCount = self.dashCount + 1
    self.dashTimer = self.dashTimer + 1

end



-- checks two tiles to our left to see if a collision occurred
function Player:checkLeftCollision()
    if self.dx < 0 then
        -- check if there's a tile directly beneath us
        if self.map:collides(self.map:tileAt(self.x - 1, self.y)) or
            self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height - 1)) then
            
            -- if so, reset velocity and position and change state
            self.dx = 0
            self.x = self.map:tileAt(self.x - 1, self.y).x * self.map.tileWidth
        end
    end
end

-- checks two tiles to our right to see if a collision occurred
function Player:checkRightCollision()
    if self.dx > 0 then
        -- check if there's a tile directly beneath us
        if self.map:collides(self.map:tileAt(self.x + self.width, self.y)) or
            self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height - 1)) then
            
            -- if so, reset velocity and position and change state
            self.dx = 0
            self.x = (self.map:tileAt(self.x + self.width, self.y).x - 1) * self.map.tileWidth - self.width
        end
    end
end

function Player:render()

    if gameState == 'select' then
        -- draw select screen by placing p1 in 4 different positions
        love.graphics.setFont(smallFont)

        self.animation = self.animations['idle']
        self.state = 'idle'

        self.texture = love.graphics.newImage('graphics/pink_alien.png')
        love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x + self.xOffset + 30),
            math.floor(self.y + self.yOffset), 0, self.scaleX, 1, self.xOffset, self.yOffset)
        love.graphics.print('David Malan', math.floor(self.x + self.xOffset + 5), math.floor(self.y + self.yOffset + 12))
        love.graphics.print('P1 Press A', 0, math.floor(self.y + self.yOffset - 4))
        love.graphics.print('P2 Press Left', 0, math.floor(self.y + self.yOffset + 4))


        self.texture = love.graphics.newImage('graphics/green_alien.png')
        love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x + self.xOffset + 80),
            math.floor(self.y + self.yOffset), 0, self.scaleX, 1, self.xOffset, self.yOffset)
        love.graphics.print('Econ', math.floor(self.x + self.xOffset + 71), math.floor(self.y + self.yOffset + 12))
        love.graphics.print('P1 Press S', 171, math.floor(self.y + self.yOffset - 4))
        love.graphics.print('P2 Press Down', 153, math.floor(self.y + self.yOffset + 4))

        self.texture = love.graphics.newImage('graphics/blue_alien.png')
        love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x + self.xOffset + 30),
            math.floor(self.y + self.yOffset - 50), 0, self.scaleX, 1, self.xOffset, self.yOffset)
        love.graphics.print('STEM', math.floor(self.x + self.xOffset + 20), math.floor(self.y + self.yOffset - 38))
        love.graphics.print('P1 Press W', 0, math.floor(self.y + self.yOffset - 54))
        love.graphics.print('P2 Press Up', 0, math.floor(self.y + self.yOffset - 46))
            
        self.texture = love.graphics.newImage('graphics/red_alien.png')
        love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x + self.xOffset + 80),
            math.floor(self.y + self.yOffset - 50), 0, self.scaleX, 1, self.xOffset, self.yOffset)
        love.graphics.print('Humanities', math.floor(self.x + self.xOffset + 60), math.floor(self.y + self.yOffset - 38))
        love.graphics.print('P1 Press D', 171, math.floor(self.y + self.yOffset - 54))
        love.graphics.print('P2 Press Right', 153, math.floor(self.y + self.yOffset - 46))

        love.graphics.setFont(bigFont)
    else
        
        self.scaleX = 1

        -- set negative x scale factor if facing left, which will flip the sprite
        -- when applied
        if self.direction == 'right' then
            self.scaleX = 1
        else
            self.scaleX = -1
        end

        -- draw sprite with scale factor and offsets
        love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x + self.xOffset),
            math.floor(self.y + self.yOffset), 0, self.scaleX, 1, self.xOffset, self.yOffset)
    end

    -- snake
    for i, snake in ipairs(self.snakesright) do
        love.graphics.draw(self.snakeImg, snake.x, snake.y)
    end
    for i, snake in ipairs(self.snakesleft) do
        love.graphics.draw(self.snakerevImg, snake.x, snake.y)
    end    

    -- bullet
    for i, bullet in ipairs(self.bulletsright) do
        love.graphics.draw(self.bulletImg, bullet.x, bullet.y)
    end
    for i, bullet in ipairs(self.bulletsleft) do
        love.graphics.draw(self.bulletImg, bullet.x, bullet.y)
    end
    
    --book
    for i, book in ipairs(self.booksright) do
        love.graphics.draw(self.bookImg, book.x, book.y)
    end

    for i, book in ipairs(self.booksleft) do
        love.graphics.draw(self.bookImg, book.x, book.y)
    end



end
