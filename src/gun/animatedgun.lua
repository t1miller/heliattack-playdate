import "CoreLibs/crank"
import "CoreLibs/timer"

import 'ammo/projectile'
import 'ammo/spear'
import 'library/AnimatedSprite'


-- local references
local gfx <const> = playdate.graphics
local time <const> = playdate.timer
local min, max, abs, floor, cos, rad, sin, atan = math.min, math.max, math.abs, math.floor, math.cos, math.rad, math.sin, math.atan


class("AnimatedGun").extends(AnimatedSprite)
function AnimatedGun:init(gunType)
    AnimatedGun.super.init(self,gfx.imagetable.new(gunType.imgTable))

    self.gun = gunType
    self.prevFiredTime = nil
    self.angle = 0
    self.isImageFlipped = false
    self.autoAimEnabled = true
    self.autoFireEnabled = false
    self.helicopterX = 0
    self.helicopterY = 0

	self:addState("run", 1, 14, {frames = self.gun.framesNormal, loop=false})
    self:addState("run_flipped", 1, 14, {frames = self.gun.framesFlipped, loop=false})
    self:addState("idle_yes_fire", self.gun.framesIdleReloaded, self.gun.framesIdleReloaded, {loop=false})
    self:addState("idle_yes_fire_flipped", self.gun.framesIdleReloadedFlipped, self.gun.framesIdleReloadedFlipped, {loop=false})
    self:addState("idle_no_fire", self.gun.framesIdleNotReloaded, self.gun.framesIdleNotReloaded, {loop=false})
    self:addState("idle_no_fire_flipped", self.gun.framesIdleNotReloadedFlipped, self.gun.framesIdleNotReloadedFlipped, {loop=false})
	self:changeState("idle_yes_fire", true)
	self:setZIndex(1000)

    self.shootingTimer = time.keyRepeatTimerWithDelay(self.gun.reloadTime * 1000, self.gun.reloadTime * 1000, function ()
        if self.autoFireEnabled then
            -- button is held down, keep shooting
            self:shoot()
        else
            -- button released, stop shooting
            self:startReadyToShootAnimation()
            if self.shootingTimer then
                self.shootingTimer:pause()
            end
        end
        
    end)
    -- todo double check this
    -- self.shootingTimer.discardOnCompletion = false
    self.shootingTimer:pause()

    return self
end


-- todo optimization
-- if difference in angle is < 2 dont set rotation
function AnimatedGun:update()
    if self.autoAimEnabled then
        self.angle = self:autoAim()
    else
        self.angle = playdate.getCrankPosition()
    end
    self:flipImageIfNeeded(self.angle)
    self:setRotation(self.angle)
    self:updateAnimation()
end

--  h
--     p
-- opposite = (helicopterY - self.y)
-- adjacent = abs(helicopterX - self.x)
-- +270 instead of -90 makes flipImageIfNeeded work as expected 
function AnimatedGun:autoAim()
    local opposite = self.x - self.helicopterX - HELICOPTER_WIDTH/2
    local adjacent = self.helicopterY - self.y
    return atan(opposite/adjacent)*(180/3.14) + 270
end

--    270
-- 180-|-0
--    90
function AnimatedGun:flipImageIfNeeded(angle)
    if angle > 90 and angle < 270 and not self.isImageFlipped then
        self.isImageFlipped = true
        if self:canFire() then
            self:changeState("idle_yes_fire_flipped", true)
        else
            self:changeState("idle_no_fire_flipped", true)
        end
    elseif angle < 90 or angle > 270 and self.isImageFlipped then
        self.isImageFlipped = false
        if self:canFire() then
            self:changeState("idle_yes_fire", true)
        else
            self:changeState("idle_no_fire", true)
        end
    end

end

-- update helicopter and player x,y
function AnimatedGun:updateXY(x, y, helicopterX, helicopterY)
    self.helicopterX = helicopterX
    self.helicopterY = helicopterY
    self:moveTo(
        x + self.gun.xOffsetFixed + self.gun.xOffset * cos(rad(self.angle)),
        y + self.gun.yOffsetFixed + self.gun.yOffset * sin(rad(self.angle))
    )
end

-- this controls the gun image to show the gun is in the ready to fire
-- positions or its still waiting to reload
function AnimatedGun:startReadyToShootAnimation()
    if self.isImageFlipped then
        self:changeState("idle_yes_fire_flipped", true)
    else
        self:changeState("idle_yes_fire", true)
    end
end

function AnimatedGun:startShootingAnimation()
    if self.isImageFlipped then
        self:changeState("run_flipped", true)
    else
        self:changeState("run", true)
    end
end

function AnimatedGun:shoot()
    self.prevFiredTime = playdate.getCurrentTimeMilliseconds()
    self:startShootingAnimation()
    self:shootBulletOrProjectile(self.gun, self.x, self.y, self.angle)
    if self.gun.ammo <= 0 then
        self:outOfAmmoCallback()
    end
end

-- while b button held down keep shooting
function AnimatedGun:startShooting(outOfAmmoCallback)
    self.outOfAmmoCallback = outOfAmmoCallback
    -- need to reset the gun animation
    if self:canFire() then
        self.autoFireEnabled = true
        self:shoot()
        self.shootingTimer:reset()
        self.shootingTimer:start()
    end
end

-- when b button is un pressed stop shooting
function AnimatedGun:stopShooting()
    self.autoFireEnabled = false
end

function AnimatedGun:shootBulletOrProjectile(gun, x, y, angle)
    local ammoParams = deepcopy(AMMO_TYPE[gun.ammoType])

    if gun.tag == "machinegun" then
        Bullet(x, y, angle, ammoParams)
    elseif gun.tag == "uzi" then
        Bullet(x, y+4, angle, ammoParams)
        Bullet(x, y, angle, ammoParams)
    elseif gun.tag == "shotgun" then
        for i=1,  ammoParams.peletsPerShot do
            Bullet(x, y, (angle - 25) + i * 4, ammoParams)
        end
    elseif gun.tag == "railgun" then
        local projectile = Projectile(x, y, angle, deepcopy(AMMO_TYPE.RAIL.PROJECTILE))
        Bullet(x, y, angle, deepcopy(AMMO_TYPE.RAIL.BULLET), function ()
            projectile:removeMe()
        end)
    elseif gun.tag == "speargun" then
        Spear(self, x, y, angle, ammoParams)
    elseif gun.tag == "minigun" then
        -- MiniGun(self.x, self.y)
        -- todo make mini gun extend gunanimation
        -- probably just need to add an extra state to animated sprite called hit
        -- then we can reuse all autoaim, flip image, etc, 
    else
        Projectile(x, y, angle, ammoParams)
    end

    self.gun.ammo -= 1
end

function AnimatedGun:canFire()
    return not self.prevFiredTime or self.gun.ammo <= 0
           or playdate.getCurrentTimeMilliseconds() - self.prevFiredTime >= self.gun.reloadTime*1000
end

function AnimatedGun:getReloadProgress()
    if not self.prevFiredTime then
        return 0
    else
        local timeRemainingRatio = (playdate.getCurrentTimeMilliseconds() - self.prevFiredTime) / (self.gun.reloadTime * 1000)
        local timeRemainingPercent = timeRemainingRatio * 100
        if timeRemainingPercent > 100 then
            -- no reload neccessary, we can shoot immediately
           return 0
        else
            return timeRemainingPercent
        end
    end
end

function AnimatedGun:removeMe()
    if self.shootingTimer then
        self.shootingTimer:remove()
    end
    self:remove()
end



