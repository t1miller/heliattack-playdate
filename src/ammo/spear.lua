import 'CoreLibs/easing'
import 'CoreLibs/timer'


-- local references
local gfx = playdate.graphics
local cos, rad, sin = math.cos, math.rad, math.sin


class("Spear").extends(gfx.sprite)
function Spear:init(parent, x, y, angle, ammoType)
    Spear.super.init(self)

    self.parent = parent
    self.ammo = ammoType
    self.angle = angle

    self:setImage(self.ammo.imgTable)
    self:setZIndex(1100)
    self:setRotation(angle)
    self:setCollideRect(0, 0, self.width, self.height)
    self:moveTo(
        x + self.ammo.xOffset * cos(rad(angle)),
        y + self.ammo.yOffset * sin(rad(angle))
    )
    self:addSprite()

    self.spearGunX = self.x
    self.spearGunY = self.y

    self.ropeSprite = gfx.sprite.new()
    self.ropeSprite:setSize(BACKGROUND_WIDTH, DISPLAY_HEIGHT)
    self.ropeSprite:setZIndex(1100)
    self.ropeSprite:moveTo(0, 0)
    self.ropeSprite:setCenter(0, 0)
    self.ropeSprite.draw = function () --(x,y,width,height)
        gfx.pushContext()
            gfx.setColor(gfx.kColorBlack)
            gfx.setLineWidth(1)
            gfx.drawLine(self.spearGunX, self.spearGunY, self.x, self.y)
        gfx.popContext()
    end
    self.ropeSprite:addSprite()
end

function Spear:update()

    self.spearGunX = self.parent.x
    self.spearGunY = self.parent.y
    self.dx = self.ammo.easingFunction.value*cos(rad(self.angle))
    self.dy = self.ammo.easingFunction.value*sin(rad(self.angle))

    if self.pullBackSpearTimerX and self.pullBackSpearTimerX.active 
            and self.pullBackSpearTimerY and self.pullBackSpearTimerX.active then
        -- move rope and spear in backwards direction
        self:moveTo(self.pullBackSpearTimerX.value, self.pullBackSpearTimerY.value)
    else
        -- move rope and spear in forwards direction
        local x,y,c,n = self:moveWithCollisions(self.x + self.dx, self.y + self.dy)
        for i=1,n do
            local other = c[i].other
            if other.tag == "helicopter" then
                print("takedown")
                other:takeDown()
                self.pullBackSpearTimerX = playdate.frameTimer.new(10, self.x, self.spearGunX, playdate.easingFunctions.linear)
                self.pullBackSpearTimerY = playdate.frameTimer.new(10, self.y, self.spearGunY, playdate.easingFunctions.linear)
                self.removeSpearAndRopeTimer = playdate.frameTimer.new(10, function ()
                    self.ropeSprite:remove()
                    self:remove()
                end)
            elseif other.tag == "wall" then
                self:remove()
                self.ropeSprite:remove()
            end
        end
    end


    if self.x < 0 or self.x > PLAYER_MAX_X or self.y < 0 or self.y > 240 or self.removeme then
        self.ropeSprite:remove()
        self:remove()
    end
end


function Spear:collisionResponse(other)
    return "overlap"
end


