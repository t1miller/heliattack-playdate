import 'CoreLibs/easing'
import 'CoreLibs/timer'

import 'library/AnimatedSprite'

-- local references
local gfx = playdate.graphics
local cos, rad, sin = math.cos, math.rad, math.sin


class("Projectile").extends(AnimatedSprite)
function Projectile:init(x, y, angle, ammoType)
    -- xOffset, yOffset, angle, damage, useCollideRect, trajectory, imageTable, frames)
    Projectile.super.init(self, ammoType.imgTable)
    local selfself = self

    self.ammo = ammoType
    self.angle = angle

    -- if timeToKill is set automatically remove projectile after timeToKill ms
    if self.ammo.timeToKill then
        local removeMeTimer = playdate.timer.performAfterDelay(self.ammo.timeToKill*1000, function()
            selfself:removeMe()
        end)
    end

    self.easingFunction =  playdate.frameTimer.new(
        self.ammo.easingFunctionFrameDuration, 
        self.ammo.easingFunctionStartValue, 
        self.ammo.easingFunctionEndValue, 
        self.ammo.easingFunctionType
    )

	self:addState("run", 1, 6, {frames = self.ammo.frames, loop=true})
	self:setZIndex(1100)
    self:setRotation(self.angle)
    self:moveTo(
        x + self.ammo.xOffset * cos(rad(self.angle)),
        y + self.ammo.yOffset * sin(rad(self.angle))
    )
    self:changeState("run", true)

    local width, height = self.ammo.imgTable[1]:getSize()
    if self.ammo.useCollideRect then
        self:setCollideRect(0,0,width,height)
    end
end

function Projectile:update()
    self.dx = self.easingFunction.value *  cos(rad(self.angle))
    self.dy = self.easingFunction.value *  sin(rad(self.angle))
    if not self.ammo.useCollideRect then
        self:moveTo(self.x + self.dx, self.y + self.dy)
    else
        local x,y,c,n = self:moveWithCollisions(self.x + self.dx, self.y + self.dy)
        for i=1,n do
            local other = c[i].other
            if other.tag == "helicopter" then
                self:removeMe()
                other:hit(self)
            elseif other.tag == "wall" then
                self:removeMe()
            end
        end

        if self.x < 0 or self.x > PLAYER_MAX_X or self.y < 0 or self.y > 240 then
            self:removeMe()
        end
    end

    self:updateAnimation()
end

function Projectile:removeMe()
    if self.easingFunction then
        self.easingFunction:remove()
    end
    self:remove()
end

function Projectile:collisionResponse(other)
    return "overlap"
end
