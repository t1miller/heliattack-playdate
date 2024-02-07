import 'toucan'

local gfx <const> = playdate.graphics
local time <const> = playdate.timer
local rand <const> = math.random

class("Map").extends(gfx.sprite)
-- 400 x 240 
function Map:init()
    Map.super.init(self)

	self.toucans = {}
    self.tiles = {
         5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,
         5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,
         5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,
        33,  34,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,
        49,  50,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,
        65,  66,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   4,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   1,   2,   3,
        81,  82,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,  19,  20,  21,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,  54,  55,  56,
        97,  98,  99,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5, 102,   6,   7,   8,   9,  10,  11,  12,  13,  14,   5,   5,   5,   5,   5,   5,   5,   5,   5,  102,  5,   5,   5,   5,  35,  36,  37,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,  70,  72,  72,
       113, 114, 115,   5,   5,   5,   5,   5,   5,  90,  91,   5,   5, 118,  22,  23,  24,  25,  26,  27,  28,  29,  30,   5,   5,  90,  91,  84,  85,  87,  87,  87,  118, 87,  87, 131, 132,  78,  68,  67,  59,   5,   5,   5,   5,   5,   5,  93,   5,   5,   5,   5,   5,  70,  72,  72,
        55,  58,  59, 105, 105, 103,   5,   5,   5, 106, 107,   5,  54,  55,  38,  39,  40,  41,  42,  43,  44,  45,  46,  59, 105, 106, 107, 100, 101,  78,  68,  69,  67,  68,  69,  67,  68,  72,  76,  60,   5,   5,   5,   5,   5,   5, 108, 109, 110,   5,   5,  54,  55,  56,  72,  72,
        31,  32,   5, 121, 121, 119, 120,   5,   5, 122, 123,   5,  70,  80, 129, 130,   5,   5,   5,   5,   5,  70,  71,  77, 121, 122, 123,  78,  68,  73,  73,  74,  31,  32,  31,  32,  74,  73,  59,   5,   5,   5,   5,   5,   5,   5, 124, 125, 126,  54,  55,  56,  72,  72,  72,  72,
        47,  48,  69,  67,  68,  69,  67,  68,  69,  67,  68,  69,  67,  80, 145, 146, 147, 148,   5,   5,   5,  54,  74,  72,  67,  68,  69,  73,  74,  72,  72,  73,  47,  48,  47,  48,  74,  73,  69,  67,  68,  69,  67,  68,  69,  67,  68,  69,  67,  68,  71,  72,  72,  72,  72,  72,
    }

    local tilesheet = gfx.imagetable.new("images/map/map")
    self.tilemap = gfx.tilemap.new()
    self.tilemap:setImageTable(tilesheet)
    self.tilemap:setTiles(self.tiles, TILE_PER_ROW - 1)

    self:setCenter(0,0)
    self:setZIndex(0)
    self:setTilemap(self.tilemap)
    self:initToucans()
    self:initRandomFlyingToucan()
    self:setupWallSprites()
    self:add()
end

function Map:setupWallSprites()
	local walls = gfx.sprite.addWallSprites(self.tilemap, {
        5,  60, -- blank
        6,   7,   8,   9,  10,  11,  12,  13,  14, --bridge
       22,  23,  24,  25,  26,  27,  28,  29,  30, --bridge
       54,  70,  76,  59,  54,  75,-- wall foliage edges
       33,  34,  49,  50,  65,  66,  81,  82,  97,  98,  99,  113,  114,  115, -- large plant
       90,  91, 106, 107, 122, 123, -- medium plant
      103, 119, 120, -- med bush
      105, 121, -- small bush
      102, 118, -- med bush
       84,  85, 100, 101, -- med bush
       86,  87,  88, 131, 132,-- grass
        4,  19,  20,  21,  35,  36,  37,
        1,   2,   3, -- small bush
       93, 108, 109, 110, 124, 125, 126,
      129, 130, 145, 146, 147, 148, 161, 162, 163, 186, --vine
    })

    for i = 1, #walls do
        walls[i].tag = "wall"
    end
end


-- sets the tile to the new value and updates our wall edges array
function Map:setTileAtPosition(column, row, newTileValue)
	-- The tilemap isn't in a sprite,   so we have to tell the display list that it needs to redraw the changed tile.
	-- Also,   sprite.addDirtyRect uses screen instead of world coordinates so we also have to add the offset
	-- gfx.sprite.addDirtyRect(column * TILE_SIZE - TILE_SIZE + cameraX,   row * TILE_SIZE - TILE_SIZE,   TILE_SIZE,   TILE_SIZE)
	self.tilemap:setTileAtPosition(column, row, newTileValue)
end

function Map:initRandomFlyingToucan()
    local randDelay = rand(20000, 30000)
    local randomTimer = time.keyRepeatTimerWithDelay(randDelay, randDelay,
        function ()
            local randY = rand(10, 90)
            local randSpeed = rand(3, 7)
            local toucan = Toucan(-30, randY, randSpeed)
            toucan:start(TOUCAN_ANIMATION_TYPE.FLY)
        end
    )
end

function Map:initToucans()
	local toucan1 = Toucan(-30, 30, 3)
	local toucan2 = Toucan(-30, 90, 5)
	local toucan3 = Toucan(50, 145, 0)

	toucan1:start(TOUCAN_ANIMATION_TYPE.FLY)
	toucan2:start(TOUCAN_ANIMATION_TYPE.FLY)
	toucan3:startRandomAnimation()

	table.insert(self.toucans, toucan1)
	table.insert(self.toucans, toucan2)
	table.insert(self.toucans, toucan3)
end

function Map:removeToucans()
	for i=1, #self.toucans do
		self.toucans[i]:removeMe()
	end
	self.toucans = {}
end