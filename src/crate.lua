import "CoreLibs/timer"
import "CoreLibs/easing"

import 'gun_ammo_types'

-- local references
local frameTimer = playdate.frameTimer
local gfx = playdate.graphics
local min, max, abs, floor, cos, rad, sin, rand = math.min, math.max, math.abs, math.floor, math.cos, math.rad, math.sin, math.random

local PARACHUTE_Y_OFFSET = -50
local CRATE_SIZE = 30
local CRATE_TYPE = {
    {name=GUN_NAMES.ABOMB, parachuteImg="images/crates/parachuteABomb", crateImg="images/crates/abombcrate"},
    {name=GUN_NAMES.GRENADE, parachuteImg="images/crates/parachuteGrenade", crateImg="images/crates/grenadecrate"},
    {name=GUN_NAMES.RPG, parachuteImg="images/crates/parachuteBazooka", crateImg="images/crates/bazookacrate"},
    {name=GUN_NAMES.RAIL, parachuteImg="images/crates/parachuteRail", crateImg="images/crates/railcrate"},
    {name=GUN_NAMES.SPEAR, parachuteImg="images/crates/parachuteSpear", crateImg="images/crates/spearcrate"},
    {name=GUN_NAMES.SHOTGUN, parachuteImg="images/crates/parachuteShotgun", crateImg="images/crates/shotguncrate"},
}


-- rotation makes it look better but causes graphics 
-- to look jenky
class("Crate").extends(gfx.sprite)
function Crate:init(x,y)
    Crate.super.init(self)

    self.tag = "parachute"
    self.startX = x
    self.startY = y

    self.yTimer = frameTimer.new(200, PARACHUTE_Y_OFFSET, DISPLAY_HEIGHT, playdate.easingFunctions.inSine)
    -- self.rotationTimer = frameTimer.new(40, -20, 20, playdate.easingFunctions.linear)
    -- self.rotationTimer.reverses = true
    -- self.rotationTimer.repeats = true

    self.crateType = self:randomCrate()
    self:setImage(gfx.image.new(self.crateType.parachuteImg))
    self:setCenter(0, 0)
    self:setCollideRect(
        self.x + self.width/2 - CRATE_SIZE/2,
        self.y + self.height - CRATE_SIZE,
        CRATE_SIZE,
        CRATE_SIZE
    )
    -- self:setRotation(-30)
    self:moveTo(x, y + PARACHUTE_Y_OFFSET)
	self:setZIndex(700)
    self:addSprite()
end


function Crate:update()
    if self.yTimer and self.yTimer.active then
        local x,y,c,n = self:moveWithCollisions(self.x, self.yTimer.value)
        for i=1,n do
            local other = c[i].other
            if other.tag == "wall" then
                self.yTimer:remove()
                -- self.rotationTimer:remove()
                -- self:setRotation(0)
                self:crateNoParachuteSprite(
                    self.x + self.width/2 - 3,
                    self.y + self.height - CRATE_SIZE/2
                )
                self:remove()
            end
        end
    end

    -- if self.rotationTimer and self.rotationTimer.active then
    --     self:setRotation(self.rotationTimer.value)
    -- end
end

function Crate:crateNoParachuteSprite(x, y)
    local crate = gfx.sprite.new(gfx.image.new(self.crateType.crateImg))
    crate.tag = "crate"
    crate:setCollideRect(0, 0, crate.width, crate.height)
    crate:moveTo(x,y)
    crate:addSprite()
end

function Crate:randomCrate()
    local randIdx = rand(1,#CRATE_TYPE)
    return CRATE_TYPE[randIdx]
end

function Crate:getGun()
    return self.crateType.name
end

function Crate:collisionResponse(other)
    if other.tag == "wall" then
        return "slide"
    else
        return "overlap"
    end
end






