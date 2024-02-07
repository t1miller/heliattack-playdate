
local gfx <const> = playdate.graphics
local DEBUG <const> = true
local Z <const> = 6000

local BORDER_WIDTH <const> = 43
local BORDER_HEIGHT <const> = 12
local BORDER_RADIUS <const> = 26
local BORDER_THICKNESS <const> = 1
local BORDER_X_OFFSET <const> = 1
local BORDER_Y_OFFSET <const> = -2

local BACKGROUND_WIDTH <const> = 37
local BACKGROUND_HEIGHT <const> = 8
local BACKGROUND_RADIUS <const> = 26
local BACKGROUND_X_OFFSET <const> = 4
local BACKGROUND_Y_OFFSET <const> = 0

local min <const> = math.min

class('ProgressBar').extends()

function ProgressBar:init(x, y)
    ProgressBar.super.init(self)

    self.x = x
    self.y = y
    self.percent = 0

    self:initBackgroundSprite()
    self:initBorderSprite()
end

function ProgressBar:initBorderSprite()
    local borderImage = gfx.image.new(BORDER_WIDTH, BORDER_HEIGHT)
    gfx.pushContext(borderImage)
        gfx.setLineWidth(BORDER_THICKNESS)
        gfx.drawRoundRect(0, 0, BORDER_WIDTH, BORDER_HEIGHT, BORDER_RADIUS)
    gfx.popContext()
    self.borderSprite = gfx.sprite.new(borderImage)
    self.borderSprite:setIgnoresDrawOffset(true)
    self.borderSprite:setZIndex(Z)
    self.borderSprite:setCenter(0, 0)
    self.borderSprite:moveTo(self.x + BORDER_X_OFFSET, self.y + BORDER_Y_OFFSET)
end

function ProgressBar:initBackgroundSprite()
    local backgroundImage = gfx.image.new(BACKGROUND_WIDTH, BACKGROUND_HEIGHT)
    gfx.pushContext(backgroundImage)
        gfx.fillRoundRect(0, 0, BACKGROUND_WIDTH, BACKGROUND_HEIGHT, BACKGROUND_RADIUS)
    gfx.popContext()
    self.backgroundSprite = gfx.sprite.new(backgroundImage)
    self.backgroundSprite:setIgnoresDrawOffset(true)
    self.backgroundSprite:setZIndex(Z)
    self.backgroundSprite:setCenter(0, 0)
    self.backgroundSprite:moveTo(self.x + BACKGROUND_X_OFFSET, self.y + BACKGROUND_Y_OFFSET)
end

function ProgressBar:hide()
    self.percent = 0
    self.backgroundSprite:remove()
    self.borderSprite:remove()
    printDebug("ProgressBar: hide()", DEBUG)
end

function ProgressBar:show()
    self.backgroundSprite:add()
    self.borderSprite:add()
    self:updateProgress(0)
    printDebug("ProgressBar: show()", DEBUG)
end

function ProgressBar:updateProgress(percent)
    -- todo only update progress if its changed
    self.percent = min(percent, 100)
    self.backgroundSprite:setClipRect(
        self.backgroundSprite.x,
        self.backgroundSprite.y,
        self.percent * BACKGROUND_WIDTH/100.0,
        self.backgroundSprite.height)
    self.backgroundSprite:markDirty()
end
