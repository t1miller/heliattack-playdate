import 'CoreLibs/crank'

import 'player/player'
import 'map/map'
import 'map/crate'
import 'helicopter/helicopter'
import 'inventory'
import 'gun_ammo_types'
import 'ui/menu'
import 'ui/dialog'
import 'gun/animatedgun'
import 'library/AnimatedSprite'

-- local references
local Point <const> = playdate.geometry.point
local gfx <const> = playdate.graphics
local min <const>, max <const>, floor<const> = math.min, math.max, math.floor
local DEBUG <const> = true

-- background tile map constants
TILE_SIZE = 20
TILE_PER_ROW = 57
BACKGROUND_WIDTH = TILE_PER_ROW * TILE_SIZE
BACKGROUND_HEIGHT = 240

-- display constants
DISPLAY_WIDTH, DISPLAY_HEIGHT = playdate.display.getSize()
DISPLAY_WIDTH_HALF = DISPLAY_WIDTH / 2

-- camera constants
CAMERA_MAX_X = BACKGROUND_WIDTH - DISPLAY_WIDTH - TILE_SIZE
CAMERA_MIN_X = 0
CAMERA_X = 0
CAMERA_Y = 0

-- player constants
PLAYER_MAX_Y = 300
PLAYER_MAX_X = BACKGROUND_WIDTH - TILE_SIZE
PLAYER_MIN_X = 8
PLAYER_HEIGHT = 32
PLAYER_HEIGHT = 30
PLAYER_START_POS = Point.new(102, 210)

-- helicopter constants
HELICOPTER_WIDTH = 136


-- local player = Player()
-- local map = Map()
-- local menu = Menu()

class("Game").extends(gfx.sprite)

function Game:init()
    Game.super.init(self)

	self.helisDestroyed = 0
	self.crate = nil

    self:setZIndex(0)
	self:setCenter(0, 0)	-- set center point to center bottom
    self:addSprite()

	self.map = Map()
	self.menu = Menu()
	self.gameOverDialog = Dialog(200, 100, 260, 150, "Game Over", "",  "Ⓐ New Game")
	self.player = Player()
	self.inventory = Inventory()
	self.gun = AnimatedGun(self.inventory:getCurrentGun())
	self.helicopter = Helicopter()
end

function Game:update()
	-- dont change order of these functions
	self:updateCurrentGun()
	self:movePlayer()
	self:moveAndShootGun()
	self:moveAndShootHelicopter()
	self:addNewHelicopterAndCrateIfNeeded()
	self:updateCameraPosition(self.player.position.x)
	self:updateMenu()
end

function Game:gameOver()
	printDebug("Game: gameOverCallback()", DEBUG)
	self.gameOverDialog:setButtonCallbacks(
		-- a button clicked
		function ()
			self.gameOverDialog:dismiss()

			-- todo clear crates
			self.helisDestroyed = 0
			self.crate = nil
			
			self.player:reset()
			self.inventory:reset()

			self.helicopter = Helicopter(self.player.position.x)
			self.gun = AnimatedGun(self.inventory:getCurrentGun())

			self.map:removeToucans()
			self.map:initToucans()
		end
	)
	self.helicopter:removeMe()
	self.gun:removeMe()
	self.player:removeMe()
	self.gameOverDialog:setDescription("Helicopters Destroyed: "..self.helisDestroyed)
	self.gameOverDialog:show()
end

function Game:updateCurrentGun()
	-- disabling crank to change gun
	-- local crankTicks = playdate.getCrankTicks(2)
	-- if crankTicks == 1 then
    --     print("Forward tick")
	-- 	self.inventory:nextGun()
    -- elseif crankTicks == -1 then
    --     print("Backward tick")
	-- 	self.inventory:prevGun()
    -- end
	if playdate.buttonJustPressed("UP") then
		self.inventory:nextGun()
	end
	if not self.inventory:isGunTheSame() then
		self.gun:removeMe()
		self.gun = AnimatedGun(self.inventory:getCurrentGun())
	end
end

function Game:updateMenu()
	self.menu:updateMenu(
		self.inventory:getAmmo(),
		max(0, self.player:getHealth()),
		self.helisDestroyed,
		self.inventory:getCurrentGun(),
		self.gun:getReloadProgress()
	)
end

function Game:addNewHelicopterAndCrateIfNeeded()
	if self.helicopter.helicopterExploded then
		-- use exploded heli coord for crate
		self.crate = Crate(self.helicopter.x, self.helicopter.y)
		self.helisDestroyed += 1
		self.helicopter = Helicopter(self.player.position.x)
	end
end


function Game:moveAndShootHelicopter()
	self.helicopter:updatePlayerXY(self.player.position.x, self.player.position.y)
end


function Game:moveAndShootGun()
	-- shoot after players postion is calculated
	self.gun:updateXY(self.player.position.x, self.player.position.y, self.helicopter.x, self.helicopter.y)
	if playdate.buttonJustPressed("B") then
		self.gun:startShooting(function()
			-- out of ammo callback
			print("Game: out of ammo")
			self.inventory:removeCurrentGun()
			self.gun:removeMe()
			self.gun = AnimatedGun(self.inventory:getCurrentGun())
		end)
	elseif playdate.buttonJustReleased("B") then
		self.gun:stopShooting()
	end
end

--! Sprite Movement
function Game:movePlayer()
	-- not possible for player to fall off map
	-- if self.player.position.y > PLAYER_MAX_Y then	-- fell off of the world! Respawn at the beginning
	-- 	self.player:reset()
	-- 	self.player:moveTo(self.player.position)
	-- 	return
	-- end

	local collisions, len
	self.player.position.x, self.player.position.y, collisions, len = self.player:moveWithCollisions(self.player.position)
	self.player:setOnGround(false)
	for i = 1, len do
		
		local c = collisions[i]

		if c.other.tag == "wall" then
            if c.normal.y < 0 then	-- feet hit
                self.player.velocity.y = 0
                self.player:setOnGround(true)
            elseif c.normal.y > 0 then	-- head hit
                self.player.velocity.y = 100 -- start with some initial downward velocity when a barrier above is hit
            end
            
            if c.normal.x ~= 0 then	-- sideways hit. stop moving
                self.player.velocity.x = 0
            end
        elseif c.other.tag == "crate" or c.other.tag == "parachute" then
			print("hit crate")
			-- todo check this
			self.inventory:addItem(self.crate, self.player)
			c.other:remove()
		elseif c.other.tag == "bullet" and not c.other:isPlayerShooting() and not PERKS[PERK_NAMES.INVINCIBLE]:isPerkActive() then
			self.player:updateHealth(-AMMO_TYPE.MINIGUN_BULLET.damage)
			self.player:showBlood()
			c.other:remove()

			if self.player:getHealth() <= 0 then
				self:gameOver()
			end
		end
	end

end

-- moves the camera horizontally based on player's current position
function Game:updateCameraPosition(playerX)
	local newX = floor(max(min(playerX - DISPLAY_WIDTH_HALF + 60, CAMERA_MAX_X), CAMERA_MIN_X))

	if newX ~= -CAMERA_X then
		CAMERA_X = -newX
		gfx.setDrawOffset(CAMERA_X,0)
		playdate.graphics.sprite.addDirtyRect(newX, 0, DISPLAY_WIDTH, DISPLAY_HEIGHT)
	end
end