import 'gun_ammo_types'

class("Inventory").extends()

local max = math.max

function Inventory:init()
    Inventory.super.init(self)

    self.guns = {}
    self.gunOrder = {}
    self.currentGunIdx = 1
    self.currentGunName = ""

    --default machine gun
    -- self:addGun(GUN_NAMES.RPG)
    -- self:addGun(GUN_NAMES.GRENADE)
    -- self:addGun(GUN_NAMES.UZI)
    -- self:addGun(GUN_NAMES.MACHINE_GUN)
    -- self:addGun(GUN_NAMES.RPG)
    -- self:addGun(GUN_NAMES.SHOTGUN)
    self:addGun(GUN_NAMES.MACHINE_GUN)
    self:addGun(GUN_NAMES.RAIL)
end


function Inventory:getCurrentGun()
    -- local gunName = self.gunOrder[self.currentGunIdx]
    self.currentGunName = self.gunOrder[self.currentGunIdx]
    -- print("getCurrentGun() "..self.currentGunName.." currentIdx="..self.currentGunIdx.." numGuns="..#self.gunOrder)
    return self.guns[self.currentGunName]
end

function Inventory:getCurrentGunName()
    return self.gunOrder[self.currentGunIdx]
end

-- 1 - 9 length 9
-- idx = (9 + 1) % 9
function Inventory:nextGun()
    -- print("next gun: currentIdx="..self.currentGunIdx.." guns="..#self.gunOrder)
    self.currentGunIdx = (self.currentGunIdx % #self.gunOrder) + 1
end


function Inventory:prevGun()
    self.currentGunIdx -= 1
    if self.currentGunIdx == 0 then
        self.currentGunIdx = #self.gunOrder
    end
end

function Inventory:getAmmo()
    -- todo
    return self:getCurrentGun().ammo
end

function Inventory:reduceAmmo(amount)
    -- todo
end

function Inventory:isGunTheSame()
    local indexedGun = self.gunOrder[self.currentGunIdx]
    return indexedGun == self.currentGunName
end


function Inventory:addGun(gunName)
    if self.guns[gunName] then
        -- gun type already in inventory
        -- add more ammo of that type
        self.guns[gunName].ammo = self.guns[gunName].ammo + GUN_TYPE[gunName].ammo
    else
        -- self.guns[gunName] = GUN_TYPE[gunName]
        self.guns[gunName] = deepcopy(GUN_TYPE[gunName])
        table.insert(self.gunOrder, gunName)
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
