import 'CoreLibs/crank'

import 'player/player'
import 'map/map'
import 'map/toucan'
import 'map/crate'
import 'helicopter/helicopter'
import 'inventory'
import 'gun_ammo_types'
import 'menu'
import 'gun/animatedgun'
import 'library/AnimatedSprite'

-- local references
local Point = playdate.geometry.point
local gfx = playdate.graphics
local min, max, abs, floor, cos, rad, sin = math.min, math.max, math.abs, math.floor, math.cos, math.rad, math.sin

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



local player = Player()
local map = Map()
local menu = Menu()

class("Game").extends(gfx.sprite)

function Game:init()
    Game.super.init(self)

	self.helisDestroyed = 0
	-- self.spawnedCrate = false
	self.crate = nil

    self:setZIndex(0)
	self:setCenter(0, 0)	-- set center point to center bottom

    map:addSprite()
    player:addSprite()
    self:addSprite()

	local toucan1 = Toucan(-20,30)
	local toucan2 = Toucan(-10,60)
	local toucan3 = Toucan(-5,90)
	local toucan4 = Toucan(-40,120)

	self.inventory = Inventory()
	self.gun = AnimatedGun(self.inventory:getCurrentGun())
	self.helicopter = Helicopter()
end


function Game:update()
	self:updateCurrentGun()
	self:movePlayer()
	self:moveAndShootGun()
	self:moveAndShootHelicopter()
	-- self:addCrateIfNeeded()
	self:addNewHelicopterAndCrateIfNeeded()
	self:updateCameraPosition(player.position.x)
	self:updateMenu()
end

function Game:updateCurrentGun()
	local crankTicks = playdate.getCrankTicks(2)
	if crankTicks == 1 then
        print("Forward tick")
		self.inventory:nextGun()
    elseif crankTicks == -1 then
        print("Backward tick")
		self.inventory:prevGun()
    end
	if playdate.buttonJustPressed("UP") then
		self.inventory:nextGun()
	end
	if not self.inventory:isGunTheSame() then
		self.gun:removeMe()
		self.gun = AnimatedGun(self.inventory:getCurrentGun())
	end
end

function Game:updateMenu()
	menu:updateMenu(
		self.inventory:getAmmo(),
		player:getHealth(),
		self.helisDestroyed,
		self.inventory:getCurrentGun()
	)
end

function Game:addCrateIfNeeded()
	-- create a crate only if the helicopter is exploding
	-- and you havent made a crate for this helicopter yet
	-- if self.helicopter.shouldExplode and self.helisDestroyed > 0
	-- 		-- and self.helisDestroyed % 2 == 0 and not self.spawnedCrate then
	-- 		and not self.spawnedCrate then
	-- 	self.crate = Crate(self.helicopter.x, self.helicopter.y)
	-- 	self.spawnedCrate = true
	-- end
end


function Game:addNewHelicopterAndCrateIfNeeded()
	if self.helicopter.helicopterExploded then
		-- use exploded heli coord for crate
		self.crate = Crate(self.helicopter.x, self.helicopter.y)
		self.helisDestroyed += 1
		self.helicopter = Helicopter(player.position.x)
	end
end


function Game:moveAndShootHelicopter()
	self.helicopter:updatePlayerXY(player.position.x, player.position.y)
end


function Game:moveAndShootGun()
	-- shoot after players postion is calculated
	self.gun:updateXY(player.position.x, player.position.y, self.helicopter.x, self.helicopter.y)
	if playdate.buttonJustPressed("B") then
		self.gun:startShooting(function()
			-- out of ammo callback
			print("Game: out of ammo")
			self.inventory:removeCurrentGun()
			self.gun:removeMe()
			self.gun = AnimatedGun(self.inventory:getCurrentGun())
			-- printTable(self.gun)
		end)
	elseif playdate.buttonJustReleased("B") then
		self.gun:stopShooting()
	end
end

--! Sprite Movement
function Game:movePlayer()

	if player.position.y > PLAYER_MAX_Y then	-- fell off of the world! Respawn at the beginning
		player:reset()
		player:moveTo(player.position)
		return
	end

	local collisions, len
	player.position.x, player.position.y, collisions, len = player:moveWithCollisions(player.position)
	player:setOnGround(false)
	for i = 1, len do
		
		local c = collisions[i]

		if c.other.tag == "wall" then
			
            if c.normal.y < 0 then	-- feet hit
                player.velocity.y = 0
                player:setOnGround(true)
            elseif c.normal.y > 0 then	-- head hit
                player.velocity.y = 100 -- start with some initial downward velocity when a barrier above is hit
                -- self:handlePlayerHeadHit(c.other)
            end
            
            if c.normal.x ~= 0 then	-- sideways hit. stop moving
                player.velocity.x = 0
            end
            
        elseif c.other.tag == "crate" or c.other.tag == "parachute" then
			print("hit crate")
			-- local gunName = c.other:getGun()
			self.inventory:addGun(self.crate:getGun())
			c.other:remove()
			-- todo add crate gun to inventory
		elseif c.other.tag == "bullet" and not c.other:isPlayerShooting() and not PLAYER_METADATA.isInvinsible then
			player:updateHealth(-1 * AMMO_TYPE.MINIGUN_BULLET.damage)
			player:showBlood(player.position.x, player.position.y)
			c.other:remove()
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
