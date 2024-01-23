import 'blood'

-- local references
local Point = playdate.geometry.point
local Rect = playdate.geometry.rect
local vector2D = playdate.geometry.vector2D
local gfx = playdate.graphics
local affineTransform = playdate.geometry.affineTransform
local min, max, abs, floor, cos, rad, sin = math.min, math.max, math.abs, math.floor, math.cos, math.rad, math.sin

-- constants
local dt = 0.05					-- time between frames at 20fps
local MAX_VELOCITY = 600
local GRAVITY_CONSTANT = 1680
local GRAVITY_STEP = vector2D.new(0, GRAVITY_CONSTANT * dt)
local JUMP_VELOCITY = 390
local SUPERJUMP_VELOCITY = 440
local MAX_JUMP_VELOCITY = 420
local MAX_FALL_VELOCITY = 280
local GROUND_FRICTION = 0.8			-- could be increased for different types of terrain
local RUN_VELOCITY = 14 			-- velocity change for running
local AIR_RUN_VELOCITY = 10 			-- velocity change for moving in the air
local SPEED_OF_RUNNING = 50			-- thea velocity at which we decide the player is running rather than walking
local LEFT, RIGHT = 1, 2
local STAND, RUN1, RUN2, RUN3, JUMP, CROUCH = 1, 2, 3, 4, 5, 6
-- timer used for player jumps
local jumpTimer = playdate.frameTimer.new(5, 45, 45, playdate.easingFunctions.outQuad)
jumpTimer:pause()
jumpTimer.discardOnCompletion = false

local spriteWidth = 17
local onGround = true		-- true if player's feet are on the ground
local crouch = false
local facing = RIGHT
-- local MAX_RUN_VELOCITY = 240
local MAX_RUN_VELOCITY = 120
local runImageIndex = 1


class("Player").extends(gfx.sprite)
-- 400 x 240 
function Player:init()
    Player.super.init(self)

	self.playerImages = playdate.graphics.imagetable.new('images/player')
	self:setImage(self.playerImages:getImage(1))
    self:setZIndex(1000)
	self:setCenter(0.5, 1)	-- set center point to center bottom middle
    self:moveTo(PLAYER_START_POS)
	self:setCollideRect(0,0,spriteWidth,PLAYER_HEIGHT)
	-- self:setMaxX(BACKGROUND_WIDTH - 24)

	self.position = PLAYER_START_POS
	self.velocity = vector2D.new(0,0)
	self.health = 100
	self.tag = "player"
end

function Player:reset()
	self.position = PLAYER_START_POS
	self:moveTo(PLAYER_START_POS)
	self.velocity = vector2D.new(0,0)
	self.health = 100
end

function Player:collisionResponse(other)
	if other.tag == "wall" then
		return "slide"
	else
		return "overlap"
	end
	-- return "slide"
end


function Player:update()

	if playdate.buttonIsPressed("down") and onGround then
		self:setCrouching(true)
	else
		
		if onGround then
			self:setCrouching(false)
		end
		
		if playdate.buttonIsPressed("left") then
			if onGround then
				self:runLeft()
			else
				self:airRunLeft()	-- can still move left and right in the air, but not as quickly
			end
			
		elseif playdate.buttonIsPressed("right") then
			if onGround then
				self:runRight()
			else
				self:airRunRight()
			end

		end
	end


	if onGround and (crouch == true or (playdate.buttonIsPressed("left") == false and playdate.buttonIsPressed("right") == false)) then
		self.velocity.x = self.velocity.x * GROUND_FRICTION
	end

	if playdate.buttonJustPressed("A") or playdate.buttonJustPressed("UP") then
		self:jump()
	elseif playdate.buttonIsPressed("A") or playdate.buttonIsPressed("UP")then
		self:continueJump()
	end


	-- gravity
	self.velocity = self.velocity + GRAVITY_STEP

	-- don't accellerate past max velocity
	if self.velocity.x > MAX_RUN_VELOCITY then self.velocity.x = MAX_RUN_VELOCITY
	elseif self.velocity.x < -MAX_RUN_VELOCITY then self.velocity.x = -MAX_RUN_VELOCITY
	end

	if self.velocity.y > MAX_FALL_VELOCITY then self.velocity.y = MAX_FALL_VELOCITY 
	elseif self.velocity.y < -MAX_JUMP_VELOCITY then self.velocity.y = -MAX_JUMP_VELOCITY
	end
	
	-- update the index used to control which frame of the run animation Player is in. Switch frames faster when running quickly.
	if abs(self.velocity.x) < 10 then
		self.velocity.x = 0
		runImageIndex = 1
	elseif abs(self.velocity.x) < 140 then
		runImageIndex = runImageIndex + 0.5
	else
		runImageIndex = runImageIndex + 1
	end
	
	if runImageIndex > 3.5 then runImageIndex = 1 end
		
	
	-- update Player position based on current velocity
	local velocityStep = self.velocity * dt
	self.position = self.position + velocityStep

	-- don't move outside the walls of the game
	if self.position.x < PLAYER_MIN_X then
		self.velocity.x = 0
		self.position.x = PLAYER_MIN_X
	elseif self.position.x > PLAYER_MAX_X then
		self.velocity.x = 0
		self.position.x = PLAYER_MAX_X
	end

	self:updateImage()
end

function Player:updateHealth(health)
	self.health += health
	print("Player: health="..self.health)
	if self.health <= 0 then
		self:reset()
	end
end

-- sets the appropriate sprite image for Player based on the current conditions
function Player:updateImage()

	if crouch then
		
		if facing == LEFT then
			self:setImage(self.playerImages:getImage(CROUCH), "flipX")
		else
			self:setImage(self.playerImages:getImage(CROUCH))
		end
		
	elseif onGround then
		if facing == LEFT then
			if self.velocity.x == 0 then
				self:setImage(self.playerImages:getImage(STAND), "flipX")
			else
				self:setImage(self.playerImages:getImage(floor(runImageIndex+1)), "flipX")
			end
		else
			if self.velocity.x == 0 then
				self:setImage(self.playerImages:getImage(STAND))
			else
				self:setImage(self.playerImages:getImage(floor(runImageIndex+1)))
			end
		end
	else
		if facing == LEFT then
			self:setImage(self.playerImages:getImage(JUMP), "flipX")
		else
			self:setImage(self.playerImages:getImage(JUMP))
		end
	end

end


function Player:showBlood(x,y)
	-- show blood
	-- local bloodSprite = AnimatedSprite(bloodImgTable)
	-- bloodSprite:moveTo(x,y)
	-- bloodSprite:setZIndex(1100)
	-- bloodSprite:playAnimation()
	local blood = Blood(x,y)
end


function Player:setOnGround(flag)
	onGround = flag
end


function Player:setCrouching(flag)
	crouch = flag
	
	if crouch then
		PLAYER_HEIGHT = 22
	else
		PLAYER_HEIGHT = 30
	end
	self:setCollideRect(0,30-PLAYER_HEIGHT,spriteWidth,PLAYER_HEIGHT)
end


function Player:isCrouching()
	return crouch
end


function Player:runLeft()
	facing = LEFT
	self.velocity.x = max(self.velocity.x - RUN_VELOCITY, -MAX_VELOCITY)
end


function Player:runRight()
	facing = RIGHT
	self.velocity.x = min(self.velocity.x + RUN_VELOCITY, MAX_VELOCITY)
	
end


function Player:airRunLeft()
	facing = LEFT
	self.velocity.x = self.velocity.x - AIR_RUN_VELOCITY
	if self.velocity.y < -MAX_VELOCITY then self.velocity.x = -MAX_VELOCITY end
end


function Player:airRunRight()
	facing = RIGHT
	self.velocity.x = self.velocity.x + AIR_RUN_VELOCITY
	if self.velocity.x > MAX_VELOCITY then self.velocity.x = MAX_VELOCITY end
end


function Player:jump()
	
	-- if feet on ground
	if onGround then
		
		if playdate.buttonIsPressed("A") and abs(self.velocity.x) > SPEED_OF_RUNNING then -- super jump
			self.velocity.y = -SUPERJUMP_VELOCITY
		else -- regular jump
			self.velocity.y = -JUMP_VELOCITY
		end
		
		jumpTimer:reset()
		jumpTimer:start()
		
	end
	
end

function Player:continueJump()
	self.velocity.y = self.velocity.y - jumpTimer.value
end
