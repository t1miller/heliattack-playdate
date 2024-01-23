
-- local references
local gfx = playdate.graphics
local cos, rad, sin = math.cos, math.rad, math.sin


class("Bullet").extends(gfx.sprite)
function Bullet:init(x, y, angle, ammoType, hitCallback)
    Bullet.super.init(self)
    
    self.tag = "bullet"
    self.ammo = ammoType
    self.dx = (self.ammo.speed) * cos(rad(angle))
    self.dy = (self.ammo.speed) * sin(rad(angle))
    self.bulletWidth = self.ammo.width or 3
    self.bulletHeight = self.ammo.height or 3
    self.hitCallback = hitCallback

    self:setSize(self.bulletWidth, self.bulletHeight)
	self:setCollideRect(0, 0, self.bulletWidth, self.bulletHeight)
    self:setZIndex(1100)
    self:moveTo(
        x,
        y
    )
    self:addSprite()
end


function Bullet:update()
    local x,y,c,n = self:moveWithCollisions(self.x + self.dx, self.y + self.dy)
    for i=1,n do
        local other = c[i].other
        if self.ammo.isPlayerShooting and other.tag == "helicopter" then
            other:hit(self)
            self:remove()
        elseif other.tag == "wall" then
            if self.hitCallback then
                self.hitCallback()
            end
            self:remove()
        end
    end
    
    if self.x < 0 or self.x > PLAYER_MAX_X or self.y < 0 or self.y > 240 then
        if self.hitCallback then
            self.hitCallback()
        end
        self:remove()
    end
end


function Bullet:draw()
    if self.ammo.color then
        gfx.setColor(self.ammo.color)
    else
        gfx.setColor(gfx.kColorBlack)
    end
    gfx.fillRect(0, 0, self.bulletWidth, self.bulletHeight)
end


function Bullet:isPlayerShooting()
    return self.ammo.isPlayerShooting
end



function Bullet:collisionResponse(other)
    return "overlap"
end
