
require 'Util'

Map = Class{}

--brick and empty tiles
TILE_BRICK = 1
TILE_EMPTY = -1

-- cloud tiles
CLOUD_LEFT = 6
CLOUD_RIGHT = 7

-- bush tiles
BUSH_LEFT = 2
BUSH_RIGHT = 3

-- mushroom tiles
MUSHROOM_TOP = 10
MUSHROOM_BOTTOM = 11

-- jump block
JUMP_BLOCK = 5
JUMP_BLOCK_HIT = 9

-- a speed to multiply delta time to scroll map; smooth value
local SCROLL_SPEED = 62

-- constructor for our map object
function Map:init()

    self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
    self.sprites = generateQuads(self.spritesheet, 16, 16)
    self.music = love.audio.newSource('sounds/music.wav', 'static')
    self.sounds = {
        ['death'] = love.audio.newSource('sounds/death.wav', 'static'),
        ['victory'] = love.audio.newSource('sounds/victory.wav', 'static')
    }

    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth = 30
    self.mapHeight = 28
    self.tiles = {}

    -- applies positive Y influence on anything affected
    self.gravity = 20

    -- associate player with map
    self.player = Player(self)
    self.player2 = Player2(self)

    -- cache width and height of map in pixels
    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    -- first, fill map with empty tiles
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            
            -- support for multiple sheets per tile; storing tiles as tables 
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    -- begin generating the terrain using vertical scan lines
    local x = 1
    while x < self.mapWidth do
         
        self:setTile(x, self.mapHeight/4, MUSHROOM_TOP)

        -- creates column of tiles going to bottom of map
        for y = self.mapHeight / 4 + 1, self.mapHeight do
            self:setTile(x, y, MUSHROOM_BOTTOM)
        end

        -- next vertical scan line
            x = x + 1
 
    end

    -- start the background music
    self.music:setLooping(true)
    self.music:play()
end

-- return whether a given tile is collidable
function Map:collides(tile)
    -- define our collidable tiles
    local collidables = {
        TILE_BRICK, JUMP_BLOCK, JUMP_BLOCK_HIT,
        MUSHROOM_TOP, MUSHROOM_BOTTOM
    }

    -- iterate and return true if our tile type matches
    for _, v in ipairs(collidables) do
        if tile.id == v then
            return true
        end
    end

    return false
end

function Map:update(dt)
    self.player:update(dt)
    self.player2:update(dt)
    self:clash()

    --call collision detection for specials if not blocking
    if self.player.skin == 1 and self.player2.playerState ~= 'block' then
        self:p1bulletr()
        self:p1bulletl()
    end

    if self.player.skin == 2 and self.player2.playerState ~= 'block' then
        self:p1bookl()
        self:p1bookr()
    end

    if self.player.skin == 4 and self.player2.playerState ~= 'block' then 
        self:p1snakel()
        self:p1snaker()
    end

    if self.player2.skin == 1 and self.player.playerState ~= 'block' then 
        self:p2bulletl()
        self:p2bulletr()
    end

    if self.player2.skin == 2 and self.player.playerState ~= 'block' then 
        self:p2bookl()
        self:p2bookr()
    end

    if self.player2.skin == 4 and self.player.playerState ~= 'block' then 
        self:p2snakel()
        self:p2snaker()
    end
end

-- gets the tile type at a given pixel coordinate
function Map:tileAt(x, y)
    return {
        x = math.floor(x / self.tileWidth) + 1,
        y = math.floor(y / self.tileHeight) + 1,
        id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
    }
end

-- returns an integer value for the tile at a given x-y coordinate
function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end

-- sets a tile at a given x-y coordinate to an integer value
function Map:setTile(x, y, id)
    self.tiles[(y - 1) * self.mapWidth + x] = id
end

-- renders our map to the screen, to be called by main's render
function Map:render()
    if gameState == 'select' then
        self.music:play()

        --selection screen cursor
        if self.player.skin == 1 then
            love.graphics.setFont(bigFont) 
            love.graphics.print("P1", 62, 55)
        elseif self.player.skin == 2 then
            love.graphics.setFont(bigFont)
            love.graphics.print("P1", 113, 55)
        elseif self.player.skin == 3 then
            love.graphics.setFont(bigFont)
            love.graphics.print("P1", 62, 105)
        elseif self.player.skin == 4 then
            love.graphics.setFont(bigFont)
            love.graphics.print("P1", 113, 105)
        end

        if self.player2.skin == 1 then
            love.graphics.setFont(bigFont) 
            love.graphics.print("P2", 84, 55)
        elseif self.player2.skin == 2 then
            love.graphics.setFont(bigFont)
            love.graphics.print("P2", 135, 55)
        elseif self.player2.skin == 3 then
            love.graphics.setFont(bigFont)
            love.graphics.print("P2", 84, 105)
        elseif self.player2.skin == 4 then
            love.graphics.setFont(bigFont)
            love.graphics.print("P2", 135, 105)
        end
    elseif gameState == 'title' then
    --build map
    else
        for y = 1, self.mapHeight do
            for x = 1, self.mapWidth do
                local tile = self:getTile(x, y)
                if tile ~= TILE_EMPTY then
                    love.graphics.draw(self.spritesheet, self.sprites[tile],
                        (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
                end
            end
        end
    end

    self.player:render()
    self.player2:render()
end

--collision detection and score counting for kick
function Map:clash()
    if self.player.x > self.player2.x + self.player2.width or self.player.x + self.player.width < self.player2.x then
    
    elseif self.player.y > self.player2.y + self.player2.height or self.player.y + self.player.height < self.player2.y then
    
    else
        if self.player.playerState == 'attack' and self.player2.playerState == 'attack' then

        elseif self.player.playerState == 'attack' then
            p1score = p1score + 1
            roundWinner = 1
            self:reset()
            if p1score == 7 then
                gameState = 'victory'
                self.music:pause()
                self.sounds['victory']:play()
            end
        elseif self.player2.playerState == 'attack' then
            p2score = p2score + 1
            roundWinner = 2
            self:reset()
            if p2score == 7 then
                gameState = 'victory'
                self.music:pause()
                self.sounds['victory']:play()
            end
        end
    end
end

--resets characters, projectiles each round
function Map:reset()
    self.sounds['death']:play()

    table.remove(self.player.bulletsright, j)
    table.remove(self.player.bulletsleft, j)
    table.remove(self.player.booksleft, j)
    table.remove(self.player.booksright, j)
    table.remove(self.player.snakesleft, j)
    table.remove(self.player.snakesright, j)
    table.remove(self.player2.bulletsright, j)
    table.remove(self.player2.bulletsleft, j)
    table.remove(self.player2.booksleft, j)
    table.remove(self.player2.booksright, j)
    table.remove(self.player2.snakesleft, j)
    table.remove(self.player2.snakesright, j)

    self.player.animation = self.player.animations['idle']
    self.player2.animation = self.player2.animations['idle']
    self.player.state = 'idle'
    self.player2.state = 'idle'

    self.player.x = self.tileWidth * 10 - 116
    self.player.y = self.tileHeight * ((self.mapHeight) / 4) - 36
    self.player2.x = self.tileWidth * 10 - 16
    self.player2.y = self.tileHeight * ((self.mapHeight) / 4) - 36

    self.player.dx = 0
    self.player.dy = 0
    self.player2.dx = 0
    self.player2.dy = 0 

    self.player.playerState = 'neutral'
    self.player2.playerState = 'neutral'

    gameState = 'ready'
end

--hit calculation and score counting for specials in 12 cases :(
--player 1 hit detection
function Map:p1bulletr()
    for j, bullet in ipairs(self.player.bulletsright) do 
        if CheckCollision(self.player2.x, self.player2.y, self.player2.width, self.player2.height, self.player.newBullet.x, self.player.newBullet.y, 26, 10) then
            p1score = p1score + 1
            roundWinner = 1
            self:reset()
            if p1score == 7 then
                gameState = 'victory'
                self.music:pause()
                self.sounds['victory']:play()
            end
        end
    end
end

function Map:p1bulletl()
    for j, bullet in ipairs(self.player.bulletsleft) do 
        if CheckCollision(self.player2.x, self.player2.y, self.player2.width, self.player2.height, self.player.newBullet1.x, self.player.newBullet1.y, 26, 10) then
            p1score = p1score + 1
            roundWinner = 1
            self:reset()
            if p1score == 7 then
                gameState = 'victory'
                self.music:pause()
                self.sounds['victory']:play()
            end
        end
    end
end

function Map:p1bookr()
    for j, book in ipairs(self.player.booksright) do 
        if CheckCollision(self.player2.x, self.player2.y, self.player2.width, self.player2.height, self.player.newBook.x, self.player.newBook.y, 10, 10) then
            p1score = p1score + 1
            roundWinner = 1
            self:reset()
            if p1score == 7 then
                gameState = 'victory'
                self.music:pause()
                self.sounds['victory']:play()
            end
        end
    end
end

function Map:p1bookl()
    for j, book in ipairs(self.player.booksleft) do 
        if CheckCollision(self.player2.x, self.player2.y, self.player2.width, self.player2.height, self.player.newBook.x, self.player.newBook.y, 10, 10) then
            p1score = p1score + 1
            roundWinner = 1
            self:reset()
            if p1score == 7 then
                gameState = 'victory'
                self.music:pause()
                self.sounds['victory']:play()
            end
        end
    end
end

function Map:p1snaker()
    for j, snake in ipairs(self.player.snakesright) do 
        if CheckCollision(self.player2.x, self.player2.y, self.player2.width, self.player2.height, self.player.newSnake.x, self.player.newSnake.y, 20, 16) then
            p1score = p1score + 1
            roundWinner = 1
            self:reset()
            if p1score == 7 then
                gameState = 'victory'
                self.music:pause()
                self.sounds['victory']:play()
            end
        end
    end
end

function Map:p1snakel()
    for j, snake in ipairs(self.player.snakesleft) do 
        if CheckCollision(self.player2.x, self.player2.y, self.player2.width, self.player2.height, self.player.newSnake1.x, self.player.newSnake1.y, 20, 16) then
            p1score = p1score + 1
            roundWinner = 1
            self:reset()
            if p1score == 7 then
                gameState = 'victory'
                self.music:pause()
                self.sounds['victory']:play()
            end
        end
    end
end

--player 2 hit detection
function Map:p2bulletr()
    for j, bullet in ipairs(self.player2.bulletsright) do 
        if CheckCollision(self.player.x, self.player.y, self.player.width, self.player.height, self.player2.newBullet.x, self.player2.newBullet.y, 26, 10) then
            p2score = p2score + 1
            roundWinner = 2
            self:reset()
            if p2score == 7 then
                gameState = 'victory'
                self.music:pause()
                self.sounds['victory']:play()
            end
        end
    end
end

function Map:p2bulletl()
    for j, bullet in ipairs(self.player2.bulletsleft) do 
        if CheckCollision(self.player.x, self.player.y, self.player.width, self.player.height, self.player2.newBullet1.x, self.player2.newBullet1.y, 26, 10) then
            p2score = p2score + 1
            roundWinner = 2
            self:reset()
            if p2score == 7 then
                gameState = 'victory'
                self.music:pause()
                self.sounds['victory']:play()
            end
        end
    end
end

function Map:p2bookr()
    for j, book in ipairs(self.player2.booksright) do 
        if CheckCollision(self.player.x, self.player.y, self.player.width, self.player.height, self.player2.newBook.x, self.player2.newBook.y, 10, 10) then
            p2score = p2score + 1
            roundWinner = 2
            self:reset()
            if p2score == 7 then
                gameState = 'victory'
                self.music:pause()
                self.sounds['victory']:play()
            end
        end
    end
end

function Map:p2bookl()
    for j, book in ipairs(self.player2.booksleft) do 
        if CheckCollision(self.player.x, self.player.y, self.player.width, self.player.height, self.player2.newBook.x, self.player2.newBook.y, 10, 10) then
            p2score = p2score + 1
            roundWinner = 2
            self:reset()
            if p2score == 7 then
                gameState = 'victory'
                self.music:pause()
                self.sounds['victory']:play()
            end
        end
    end
end

function Map:p2snaker()
    for j, snake in ipairs(self.player2.snakesright) do 
        if CheckCollision(self.player.x, self.player.y, self.player.width, self.player.height, self.player2.newSnake.x, self.player2.newSnake.y, 20, 16) then
            p2score = p2score + 1
            roundWinner = 2
            self:reset()
            if p2score == 7 then
                gameState = 'victory'
                self.music:pause()
                self.sounds['victory']:play()
            end
        end
    end
end

function Map:p2snakel()
    for j, snake in ipairs(self.player2.snakesleft) do 
        if CheckCollision(self.player.x, self.player.y, self.player.width, self.player.height, self.player2.newSnake1.x, self.player2.newSnake1.y, 20, 16) then
            p2score = p2score + 1
            roundWinner = 2
            self:reset()
            if p2score == 7 then
                gameState = 'victory'
                self.music:pause()
                self.sounds['victory']:play()
            end
        end
    end
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
end