
import "CoreLibs/timer"
import "CoreLibs/easing"

import 'library/AnimatedSprite'
import 'gun/minigun'
import 'explosion'

-- local references
local gfx <const> = playdate.graphics
local timer <const> = playdate.timer
local frameTimer <const> = playdate.frameTimer
local Point <const> = playdate.geometry.point
local abs <const>, rand <const> =  math.abs, math.random

local HELICOPTER_HOVER_Y <const> = 0
local HELICOPTER_FLY_OUT_Y <const> = -50

local FLY_IN_X_OFFSET <const> = 600
local FLY_AWAY_INTERVAL_SECONDS <const> = 4
local FOLLOW_MAX_DISTANCE_X <const> = 150
local ANIMATION_TYPE <const> = {
    FLY_IN_RIGHT = 1,
    FLY_IN_LEFT = 2,
    FLY_AWAY_LEFT = 3,
    FLY_AWAY_RIGHT = 4,
    CONVERGE_ON_PLAYER = 5,
    FOLLOW = 6,
    TAKE_DOWN = 7,
}
local offMapPos <const> = Point.new(-130, -100)


class("Helicopter").extends(AnimatedSprite)
function Helicopter:init(playerX, playerY)
    Helicopter.super.init(self,gfx.imagetable.new("images/helicopter"))

    self.helicopterAngle = 0
    self.health = 100
    self.tag = "helicopter"
    self.helicopterExploded = false
    self.playerX = playerX or PLAYER_START_POS.x
    self.playerY = playerY or PLAYER_START_POS.y
    self.flyAwayTimer = timer.keyRepeatTimerWithDelay(FLY_AWAY_INTERVAL_SECONDS*1000, FLY_AWAY_INTERVAL_SECONDS*1000, function()
        if self.flyAwayTimer then

            -- -- dont fly away if were currently already converging 
            -- if self.xTimer and self.xTimer.active then return end

            if self:isFlyingLeft() then
                self:animate(ANIMATION_TYPE.FLY_AWAY_LEFT)
            else
                self:animate(ANIMATION_TYPE.FLY_AWAY_RIGHT)
            end
        end
    end)
    self.flyAwayTimer.delay = FLY_AWAY_INTERVAL_SECONDS * 1000

   	self:addState("fly_left", 1, 12, {frames = {1,2,3,4}, loop=true})
    self:addState("hit_left", 1, 12, {frames = {5,5,5}, loop=false})
    self:addState("fly_right", 1, 12, {frames = {7,8,9,10}, loop=true})
    self:addState("hit_right", 1, 12, {frames = {11,11,11}, loop=false})
    self:changeState("fly_left", true)
    self:moveTo(offMapPos)
	self:setZIndex(500)
    self:setCenter(0,0)
    self:setCollideRect(0, 5, self.width, self.height-10)
    self:playAnimation()
    self:animate(ANIMATION_TYPE.FLY_IN_LEFT)

    self.gun = MiniGun(self.playerX - FLY_IN_X_OFFSET, HELICOPTER_HOVER_Y)
    self.gun:startShooting()
end


function Helicopter:hit(other)
    local damageMultiplier = 1
    if PERKS[PERK_NAMES.X3_DAMAGE]:isPerkActive() then
        damageMultiplier = PERKS[PERK_NAMES.X3_DAMAGE].perkValue
    end

    self.health = self.health - other.ammo.damage * damageMultiplier
    if self.health <= 0 then
        self:explode()
        return
    end

    if self:isFlyingLeft() then
        self:changeState("hit_left", true)
        self:changeState("fly_left", false)
    else
    	self:changeState("hit_right", true)
        self:changeState("fly_right", false)
    end

    self.gun:hit()
end


function Helicopter:explode()
    Explosion(self.x, self.y, self:isFlyingLeft())
    self.helicopterExploded = true
    self:removeMe()
end


function Helicopter:collisionResponse(other)
    if other.tag == "wall" then
        return "slide"
    else
        return "overlap"
    end
end


function Helicopter:takeDown()
    -- todo
    -- freeze helicopter
    -- twist it so its facing the fround
    -- bring it down, show rope this whole time
    -- explode helicopter
    self.flyAwayTimer:remove()

    self:animate(ANIMATION_TYPE.TAKE_DOWN)
end


function Helicopter:update()
    
    if self.xTimer.active then
        -- move heli in a predefined way
        -- self:moveTo(self.xTimer.value, self.yTimer.value)
        local x,y,c,n = self:moveWithCollisions(self.xTimer.value, self.yTimer.value)
        for i=1,n do
            local other = c[i].other
            -- if the heli hits a wall or and not already set to explode
            -- then explode
            -- if other.tag == "wall" and not self.shouldExplode then
            if other.tag == "wall" then
                self:explode()
            end
        end
    else
        -- move heli at random times converging on player
        -- pos eventually
        ----heli ------ player ------- heli
        if abs(self.x - self.playerX) > FOLLOW_MAX_DISTANCE_X then
            -- if self.playerX - self.x > 0 then
            --     self:moveTo(self.x + 7, HELICOPTER_HOVER_Y)
            -- else
            --     self:moveTo(self.x - 7, HELICOPTER_HOVER_Y)
            -- end
            self:animate(ANIMATION_TYPE.CONVERGE_ON_PLAYER)
        end
    end

    if self.rotationTimer.active then
        self:setRotation(self.rotationTimer.value)
        self.helicopterAngle = self.rotationTimer.value
    end

    self.gun:updateXY(self.x, self.y, self.playerX, self.playerY, self:isFlyingLeft())

    self:updateAnimation()
end

function Helicopter:animate(animationType)
    if animationType == ANIMATION_TYPE.FLY_IN_RIGHT then

        self:changeState("fly_left", true)
        self:startAnimation(self.playerX + FLY_IN_X_OFFSET, HELICOPTER_FLY_OUT_Y, self.playerX, HELICOPTER_HOVER_Y, -20, 0, playdate.easingFunctions.inOutBack, 50, false)

    elseif animationType == ANIMATION_TYPE.FLY_IN_LEFT then

        self:changeState("fly_right", true)
        self:startAnimation(self.playerX - FLY_IN_X_OFFSET, HELICOPTER_FLY_OUT_Y, self.playerX, HELICOPTER_HOVER_Y, 20, 0, playdate.easingFunctions.inOutBack, 50, false)

    elseif animationType == ANIMATION_TYPE.FLY_AWAY_RIGHT then

        self:startAnimation(self.x, self.y, self.playerX + FLY_IN_X_OFFSET, HELICOPTER_FLY_OUT_Y, 0, 20, playdate.easingFunctions.inOutBack, 50, false, function ()
            self:animate(ANIMATION_TYPE.FLY_IN_RIGHT)
        end)

    elseif animationType == ANIMATION_TYPE.FLY_AWAY_LEFT then

        self:startAnimation(self.x, self.y, self.playerX - FLY_IN_X_OFFSET, HELICOPTER_FLY_OUT_Y, 0, -20, playdate.easingFunctions.inOutBack, 50, false, function ()
            self:animate(ANIMATION_TYPE.FLY_IN_LEFT)
        end)

    elseif animationType == ANIMATION_TYPE.CONVERGE_ON_PLAYER then

        self:startAnimation(self.x, self.y, self.playerX, HELICOPTER_HOVER_Y, 0, 0, playdate.easingFunctions.linear, 50, false)
    
    elseif animationType == ANIMATION_TYPE.TAKE_DOWN then

        self:startAnimation(self.x, self.y, self.playerX, self.playerY, self.helicopterAngle, self.helicopterAngle, playdate.easingFunctions.linear, 10, false, function ()
            -- self:explode()
        end)

    end
end

-- self.animatedMove(self.x, self.y, )
function Helicopter:startAnimation(
    startX,
    startY,
    endX,
    endY,
    startRotation,
    endRotation,
    easingFunction,
    frames,
    reverses,
    timerDoneCallback)

    -- print("animateMove startX="..startX.." startY="..startY.." endX="..endX.." endY="..endY.." frames"..frames)
    self:stopAllTimers()

    if startRotation ~= endRotation then
        self.rotationTimer = frameTimer.new(frames, startRotation, endRotation, playdate.easingFunctions.linear)
        if reverses then
            self.rotationTimer.reverses = true
        end
    end

    self.xTimer =  frameTimer.new(frames, startX, endX, easingFunction)
    self.yTimer =  frameTimer.new(frames, startY, endY, easingFunction)

    if reverses then
        self.xTimer.reverses = true
        self.yTimer.reverses = true
    end

    if timerDoneCallback then
        self.animationDoneTimer = frameTimer.performAfterDelay(frames, timerDoneCallback)
    end
end

function Helicopter:stopAllTimers()

    if self.xTimer then
        self.xTimer:remove()
    end
    if self.yTimer then
        self.yTimer:remove()
    end
    if self.rotationTimer then
        self.rotationTimer:remove()
    end
    if self.animationDoneTimer then
        self.animationDoneTimer:remove()
    end
    -- if self.flyAwayTimer then
    --     self.flyAwayTimer:remove()
    -- end

end

function Helicopter:updatePlayerXY(x,y)
    self.playerX = x
    self.playerY = y
end


function Helicopter:isFlyingLeft()
    if "fly_left" == self.currentState or "hit_left" == self.currentState then
        return true
    else
        return false
    end
end

function Helicopter:removeMe()
    self:stopAllTimers()
    self.flyAwayTimer:remove()
    self.gun:stopShooting()
    self.gun:remove()
    self.gun:removeAllBulletSprites()
    self:remove()
end

function Helicopter:reset()
    -- self:stopAllTimers()
    -- self.flyAwayTimer:remove()
    -- self.gun:stopShooting()
    -- self.gun:remove()
    -- self:remove()
end
