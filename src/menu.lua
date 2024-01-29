
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
    self.gunImagePath = "images/guns/machinegun"
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

function Menu:updateMenu(ammo, health, helisDestroyed, gun)
    -- print("updateMenu() ammo:"..ammo.." health:"..health.." helisDestroyed:"..helisDestroyed.." gunImagePath"..gunImagePath)
    if ammo == self.ammo and
        health == self.health and
        helisDestroyed == self.helisDestroyed and
        gun.imgTable == self.gunImagePath then return end
    
    if gun.imgTable ~= self.gunImagePath then
        self.gunImagePath = gun.imgTable
        self.gunImage = gfx.image.new(gun.imgTable)
    end

    if gun.tag == "machinegun" then
        self.ammo = "inf"
    else
        self.ammo = ammo or self.ammo
    end

    self.health = health or self.health
    self.helisDestroyed = helisDestroyed or self.helisDestroyed

    self:markDirty()
end

function Menu:draw()
    gfx.pushContext()
        gfx.setFont(font)
        gfx.drawText("helis: " .. self.helisDestroyed, self.x+2, self.y)
        gfx.drawText("health: " .. self.health, self.x+2, self.y+11)
        gfx.drawText("ammo: " .. self.ammo, self.x+2, self.y+22)
        self.gunImage:draw(self.x+2, self.y + 35)
        gfx.setLineWidth(2)
        gfx.drawRect(self.x, self.y, 95, 50)
    gfx.popContext()
end

