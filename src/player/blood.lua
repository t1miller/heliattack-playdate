
-- local references
local gfx = playdate.graphics
local cos, rad, sin, abs = math.cos, math.rad, math.sin, math.abs


class("Blood").extends(gfx.sprite)
function Blood:init(x, y)
    Blood.super.init(self)

    self.tag = "blood"
    self.dx = 1
    self.dy = 1
    self:setCenter(0,0)
    self:setSize(15, 15)
    self:setZIndex(1200)
    -- self:moveTo(
    --     x - 12,
    --     y - 30
    -- )
    self:moveTo(
        x,
        y - 15
    )
    self.frameCount = 0
    self:addSprite()
end


function Blood:update()
    self:moveTo(self.x + self.dx, self.y + self.dy)

    self.frameCount += 1
    if self.frameCount >= 7 then
        self:remove()
    end
end


function Blood:draw()
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, 1, 1)
    gfx.fillRect(2, 2, 1, 1)
    gfx.fillRect(4, 4, 2, 2)
    gfx.fillRect(6, 5, 2, 2)
    gfx.fillRect(7, 5, 1, 1)
    gfx.fillRect(9, 0, 1, 1)
    gfx.fillRect(8, 1, 2, 2)
end

