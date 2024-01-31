import "CoreLibs/timer"

import 'library/AnimatedSprite'


-- local references
local gfx = playdate.graphics
local time = playdate.timer
local min, max, abs, floor, cos, rad, sin = math.min, math.max, math.abs, math.floor, math.cos, math.rad, math.sin

local FLY_SPEED = 5
local toucanImageTable = gfx.imagetable.new("images/map/toucan")

-- todo timer loop to on flying

class("Toucan").extends(AnimatedSprite)
function Toucan:init(x,y)
    Toucan.super.init(self, toucanImageTable)

    self.tag = "toucan"

	self:addState("fly", 1, 24, {frames = {1,2,3,4}, loop=true})
	self:addState("squack", 1, 24, {frames = {7,8,9}, loop=false})
	self:addState("look-up", 1, 24, {frames = {13,14,15,16,17,18}, loop=false})
	self:addState("look-down", 1, 24, {frames = {19,20,21,22,23,24}, loop=false})
	self:changeState("fly", true)
    self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(1000)
end



function Toucan:update()
    self:moveTo(self.x + FLY_SPEED, self.y)
    self:updateAnimation()

	if self.x < 0 or self.x > PLAYER_MAX_X or self.y < 0 or self.y > 240 then
		self:remove()
    end
end






