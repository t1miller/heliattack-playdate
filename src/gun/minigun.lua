import "CoreLibs/timer"

import 'ammo/bullet'

-- local references
local time = playdate.timer
local gfx = playdate.graphics
local min, max, abs, floor, cos, rad, sin, atan = math.min, math.max, math.abs, math.floor, math.cos, math.rad, math.sin, math.atan

local RATE_OF_FIRE = 500
local GUN_X_OFFSET = 10
local GUN_Y_OFFSET = 5
local GUN_X_FIXED_OFFSET_RIGHT = 95
local GUN_X_FIXED_OFFSET_LEFT = 40
local GUN_Y_FIXED_OFFSET = 50


local keyTimer

class("MiniGun").extends(AnimatedSprite)
function MiniGun:init(x,y)
    MiniGun.super.init(self,gfx.imagetable.new("images/guns/minigun"))

    self.tag = "minigun"
    self.angle = 90
    self.isImageFlipped = false
    self.damage = 7

	self:addState("shoot", 1, 14, {frames = {1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6}, loop=true})
    self:addState("hit", 1, 14, {frames = {7,7,7}, loop=false})
	self:addState("shoot_flipped", 1, 14, {frames = {8,8,8,9,9,9,10,10,10,11,11,11,12,12,12,13,13,13}, loop=true})
    self:addState("hit_flipped", 1, 14, {frames = {14,14,14}, loop=false})
	-- self:changeState("idle", true)
	self:setZIndex(1000)
end


---h-------
----g------
-----------
-------p---
-- SohCahToa
-- opposite = x - player.x
-- adjacent = abs(y - player.y)
-- angle = inverseTan(opp/adjacent)
function MiniGun:aim(playerX, playerY)
    local opposite = self.x - playerX
    local adjacent = abs(self.y - playerY)
    self.angle = atan(opposite/adjacent)*(180/3.14) + 90
    self:setRotation(self.angle)
end


function MiniGun:hit()
    if self.isImageFlipped then
        self:changeState("hit_flipped", true)
        self:changeState("shoot_flipped", false)
    else
        self:changeState("hit", true)
        self:changeState("shoot", false)
    end
end
-- function MiniGun:update()
--     -- self.angle = playdate.getCrankPosition()
--     -- self:setRotation(self.angle)
-- end
  
    --     270
    --      |
    -- 180 ---- 0
    --      |
    --      90  
function MiniGun:shouldFlipImage()
    if self.angle > 0 and self.angle < 90 and self.isImageFlipped then
        self.isImageFlipped = false
        self:changeState("shoot", true)
    elseif self.angle > 90 and self.angle < 180 and not self.isImageFlipped then
        self.isImageFlipped = true
        self:changeState("shoot_flipped", true)
    end
end


function MiniGun:updateXY(x,y, playerX, playerY, isFlyingLeft)
    local xOffset = GUN_X_FIXED_OFFSET_RIGHT
    if isFlyingLeft then
        xOffset = GUN_X_FIXED_OFFSET_LEFT
    end

    self:moveTo(
        x + xOffset + GUN_X_OFFSET*cos(rad(self.angle)),
        y + GUN_Y_FIXED_OFFSET + GUN_Y_OFFSET*sin(rad(self.angle))
    )

    self:aim(playerX, playerY)
end


function MiniGun:startShooting()
    self:changeState("shoot", true)
    keyTimer = time.keyRepeatTimerWithDelay(RATE_OF_FIRE, RATE_OF_FIRE, function ()
        Bullet(self.x, self.y, self.angle, AMMO_TYPE.MINIGUN_BULLET)
    end)
end


function MiniGun:stopShooting()
    keyTimer:remove()
end
