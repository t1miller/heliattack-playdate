import 'progressbar'

-- local references
local gfx <const> = playdate.graphics
local cos, rad, sin, abs = math.cos, math.rad, math.sin, math.abs
local font <const> = gfx.font.new("fonts/Roobert-9-Mono-Condensed")

local WIDTH <const> = 100

class("Menu").extends(gfx.sprite)
function Menu:init(x, y)
    Menu.super.init(self)

    self.tag = "menu"
    self.health = 100
    self.helisDestroyed = 0
    self.ammo = 0
    self.gunImagePath = "images/guns/machinegun"
    self.gunImage = gfx.image.new("images/guns/machinegun")
    self.progressBar = ProgressBar(56, 40)
    self.progress = 0.0
    self.progressBar:show()

    self:setIgnoresDrawOffset(true)
    self:setCenter(0,0)
    self:setSize(105,60)
    self:setZIndex(5000)
    self:moveTo(
        1,
        1
    )
    self:add()
end

function Menu:updateMenu(ammo, health, helisDestroyed, gun, progress)
    -- printTable(self)
    if (ammo == self.ammo or self.ammo == "inf") and
        health == self.health and
        helisDestroyed == self.helisDestroyed and
        gun.imgTable == self.gunImagePath and
        progress == self.progress then return end

    print("updateMenu() ammo:"..ammo.." health:"..health.." helisDestroyed:"..helisDestroyed.."progress:"..progress)
    print("self updateMenu() ammo:"..self.ammo.." health:"..self.health.." helisDestroyed:"..self.helisDestroyed.."progress:"..self.progress)

    
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
    self.progress = progress or self.progress

    self:markDirty()
end

function Menu:draw()
    gfx.pushContext()
        gfx.setFont(font)

        -- background 
        gfx.setColor(gfx.kColorWhite)
        gfx.setDitherPattern(0.2, gfx.image.kDitherTypeScreen)
        gfx.fillRect(self.x, self.y, WIDTH, 50)

        -- text 
        gfx.setColor(gfx.kColorBlack)
        gfx.drawText("helis:" .. self.helisDestroyed, self.x+2, self.y)
        gfx.drawText("health:" .. self.health, self.x+2, self.y+11)
        gfx.drawText("ammo:" .. self.ammo, self.x+2, self.y+22)

        -- gun image
        self.gunImage:draw(self.x+2, self.y + 34)

        -- reload 
        self.progressBar:updateProgress(self.progress)

        -- border
        gfx.setLineWidth(2)
        gfx.drawRect(self.x, self.y, WIDTH, 50)

    gfx.popContext()
end

function Menu:removeMe()
    self:remove()
end

