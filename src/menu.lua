
-- local references
local gfx = playdate.graphics
local cos, rad, sin, abs = math.cos, math.rad, math.sin, math.abs
local font = gfx.font.new("fonts/Roobert-9-Mono-Condensed")

class("Menu").extends(gfx.sprite)
function Menu:init(x, y)
    Menu.super.init(self)

    self.tag = "menu"
    self.health = 100
    self.helisDestroyed = 0
    self.ammo = 0
    self.gunImage = gfx.image.new("images/guns/machinegun")

    self:setIgnoresDrawOffset(true)
    self:setCenter(0,0)
    self:setSize(100,60)
    self:setZIndex(5000)
    self:moveTo(
        1,
        1
    )
    self:addSprite()
end

function Menu:updatePosition(x, y)
    self:moveTo(x, y)
end

function Menu:updateImg(gunImagePath)
    -- self.gunImg = gfx.image.new("images/guns/grenadelauncher")
    self.gunImage = gfx.image.new(gunImagePath)
    self:markDirty()
end

function Menu:updateAmmo(ammo)
end

function Menu:updateUserHealth(health)
end

function Menu:updateHelisDestroyed(destroyedCount)
end
-- function Menu:update()

-- end


function Menu:draw()
    gfx.pushContext()
        gfx.setFont(font)
        gfx.drawText("helis: 300",self.x+2, self.y)
        gfx.drawText("health: 100",self.x+2, self.y+11)
        gfx.drawText("ammo: 5000",self.x+2, self.y+22)
        self.gunImage:draw(self.x+2, self.y + 35)
        gfx.setLineWidth(2)
        gfx.drawRect(self.x, self.y, 95, 50)
    gfx.popContext()
    -- gfx.drawText("ammo: 80",self.x, self.y+40)
end

