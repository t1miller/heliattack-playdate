import "CoreLibs/timer"

import 'library/AnimatedSprite'


-- local references
local gfx <const> = playdate.graphics
local FLY_SPEED <const> = 5
local toucanImageTable <const> = gfx.imagetable.new("images/map/toucan")
local rand <const> = math.random
local time <const> = playdate.timer

TOUCAN_ANIMATION_TYPE = {
	FLY = "FLY",
	SQUACK = "SQUACK",
	LOOK_UP = "LOOK_UP",
	LOOK_DOWN = "LOOK_DOWN"
}

local TOUCAN_ANIMATION_NAME = {
	TOUCAN_ANIMATION_TYPE.FLY,
	TOUCAN_ANIMATION_TYPE.SQUACK,
	TOUCAN_ANIMATION_TYPE.LOOK_UP,
	TOUCAN_ANIMATION_TYPE.LOOK_DOWN
}

class("Toucan").extends(AnimatedSprite)
function Toucan:init(x, y, flySpeed)
    Toucan.super.init(self, toucanImageTable)

    self.tag = "toucan"
	self.flySpeed = flySpeed or FLY_SPEED

	self:addState(TOUCAN_ANIMATION_TYPE.FLY, 1, 24, {frames = {1,2,3,4}, loop=true})
	self:addState(TOUCAN_ANIMATION_TYPE.SQUACK, 1, 24, {tickStep = 2, frames = {7,8,9,9,9,9,8,7}, loop=false})
	self:addState(TOUCAN_ANIMATION_TYPE.LOOK_UP, 1, 24, {tickStep = 2, frames = {13,14,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,16,17,18}, loop=false})
	self:addState(TOUCAN_ANIMATION_TYPE.LOOK_DOWN, 1, 24, {tickStep = 2, frames = {19,20,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,22,23,24}, loop=false})
	self:moveTo(x, y)
	self:setZIndex(1000)
end

function Toucan:update()
    self:moveTo(self.x + self.flySpeed, self.y)
    self:updateAnimation()

	if self.x > PLAYER_MAX_X or self.y < 0 or self.y > 240 then
		self:remove()
    end
end

function Toucan:start(animationType)
	self:changeState(animationType, true)
end

function Toucan:startRandomAnimation()

	local animationRepeat = 4000
	if self.randomAnimationTimer then
		self.randomAnimationTimer:remove()
	end

	self.randomAnimationTimer = time.keyRepeatTimerWithDelay(0, animationRepeat, 
		function ()
			local randIdx = rand(2, #TOUCAN_ANIMATION_NAME)
			local randomAnimation = TOUCAN_ANIMATION_NAME[randIdx]
			self:start(randomAnimation)
		end
	)
end

function Toucan:stopRandomAnimation()
	if self.randomAnimationTimer then
		self.randomAnimationTimer:remove()
	end
end

function Toucan:removeMe()
	self:remove()
end






