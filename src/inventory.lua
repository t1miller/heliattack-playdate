import 'gun_ammo_types'

class("Inventory").extends()

local DEBUG <const> = true

function Inventory:init()
    Inventory.super.init(self)

    self:reset()
    --default machine gun
    -- self:addGun(GUN_NAMES.RPG)
    -- self:addGun(GUN_NAMES.GRENADE)
    -- self:addGun(GUN_NAMES.UZI)
    -- self:addGun(GUN_NAMES.MACHINE_GUN)
    -- self:addGun(GUN_NAMES.RPG)
    -- self:addGun(GUN_NAMES.SHOTGUN)
    -- self:addGun(GUN_NAMES.ABOMB)
    -- self:addGun(GUN_NAMES.SPEAR)
    -- self:addGun(GUN_NAMES.MACHINE_GUN)
    -- self:addGun(GUN_NAMES.RAIL)
end

function Inventory:reset()
    printDebug("Inventory: reset()", DEBUG)
    self.guns = {}
    self.gunOrder = {}
    self.currentGunIdx = 1
    self.currentGunName = ""
    self:addGun(GUN_NAMES.MACHINE_GUN)
end

function Inventory:getCurrentGun()
    self.currentGunName = self.gunOrder[self.currentGunIdx]
    return self.guns[self.currentGunName]
end

function Inventory:getCurrentGunName()
    return self.gunOrder[self.currentGunIdx]
end

-- 1 - 9 length 9
-- idx = (9 + 1) % 9
function Inventory:nextGun()
    self.currentGunIdx = (self.currentGunIdx % #self.gunOrder) + 1
end

function Inventory:prevGun()
    self.currentGunIdx -= 1
    if self.currentGunIdx == 0 then
        self.currentGunIdx = #self.gunOrder
    end
end

function Inventory:getAmmo()
    return self:getCurrentGun().ammo
end

function Inventory:isGunTheSame()
    local indexedGun = self.gunOrder[self.currentGunIdx]
    return indexedGun == self.currentGunName
end

function Inventory:addGun(gunName)
    if self.guns[gunName] then
        self.guns[gunName].ammo = self.guns[gunName].ammo + GUN_TYPE[gunName].ammo
    else
        self.guns[gunName] = deepcopy(GUN_TYPE[gunName])
        table.insert(self.gunOrder, gunName)
    end
end

function Inventory:addPerk(perkName, player)
    if perkName == PERK_NAMES.ADD_HEALTH then
        player:updateHealth(PERKS[PERK_NAMES.ADD_HEALTH].perkValue)
    else
        PERKS[perkName]:setActive()
    end
end


function Inventory:removeGun(name)
    if self.guns[name] then
        -- remove from gun order array
        for i=1, #self.gunOrder do
            if self.gunOrder[i] == name then
                table.remove(self.gunOrder, i)
                break
            end
        end

        -- remove from gun table
        self.guns[name] = nil

        -- make sure the idx is inbounds
        if self.currentGunIdx > #self.gunOrder then
            self.currentGunIdx = 1
        end

        self.currentGunName = self.gunOrder[self.currentGunIdx]
    end
end

function Inventory:removeCurrentGun()
    self:removeGun(self.currentGunName)
end

function Inventory:addItem(crate, player)
    if crate:isCrateAGun() then
        self:addGun(crate:getItemName())
    else
        self:addPerk(crate:getItemName(), player)
    end
end