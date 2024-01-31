import "CoreLibs/timer"
import "CoreLibs/easing"


-- local references
local frameTimer = playdate.frameTimer
local gfx = playdate.graphics
local min, max, abs, floor, cos, rad, sin, rand = math.min, math.max, math.abs, math.floor, math.cos, math.rad, math.sin, math.random

local leftImgTable = gfx.imagetable.new("images/helicopter-explosion-right")
local rightImgTable = gfx.imagetable.new("images/helicopter-explosion-right")
local CELL_WIDTH, CELL_HEIGHT = leftImgTable:getSize()
local IMG_WIDTH, IMG_HEIGHT = leftImgTable[1]:getSize()
local IMAGETABLE_WIDTH = CELL_WIDTH * IMG_WIDTH
local IMAGETABLE_HEIGHT = CELL_HEIGHT * IMG_HEIGHT

class("Explosion").extends(gfx.sprite)
function Explosion:init(x,y,isFlyingLeft)
    Explosion.super.init(self)
    self.expSprite = {}
    self.expVelocity = {}
    self:buildExplosionSprites(x, y, isFlyingLeft, self.expSprite, self.expVelocity)
    self:setupExplosionCleanupTimer(self.expSprite)
    self:addSprite()
end

function Explosion:update()
    for i=1, #self.expSprite do
        self.expSprite[i]:moveTo(
            self.expSprite[i].x + self.expVelocity[i].dx,
            self.expSprite[i].y + self.expVelocity[i].dy
        )
        if self.expSprite[i].x < 0 or self.expSprite[i].x > PLAYER_MAX_X
            or self.expSprite[i].y < 0 or self.expSprite[i].y > 240 then
            self.expSprite[i]:remove()
        end
    end
end

function Explosion:buildExplosionSprites(x,y,isFlyingLeft,sprites,velocitys)
    local imageTable
    if isFlyingLeft then
        imageTable = leftImgTable
    else
        imageTable = rightImgTable
    end

    for i = 1, #imageTable do
        local xOffset = floor((i-1) % CELL_WIDTH) * IMG_WIDTH
        local yOffset = floor((i-1) / CELL_WIDTH) * IMG_HEIGHT
        sprites[i] = gfx.sprite.new(imageTable[i])
        sprites[i]:moveTo(x + xOffset,y + yOffset)
        sprites[i]:setZIndex(10000)
        sprites[i]:setCenter(0,0)
        sprites[i]:add()
        -- if left, go left, if right, go right etc
        local dx,dy
        if xOffset < IMAGETABLE_WIDTH/2 then
            dx = rand(-5,-1)
        else
            dx = rand(1,5)
        end
        if yOffset < IMAGETABLE_HEIGHT/2 then
            dy = rand(-5,-1)
        else
            dy = rand(1,5)
        end
		velocitys[i] = {
            dx = dx,
            dy = dy,
		}
    end
end

function Explosion:setupExplosionCleanupTimer(sprites)
    self.removeExplosionsTimer = frameTimer.new(30, function ()
        for i=1, #sprites do
            sprites[i]:remove()
        end
        self:remove()
    end)
end




