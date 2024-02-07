
local DEBUG <const> = true

PERK_NAMES = {
    INVINCIBLE = "INVINCIBLE",
    ADD_HEALTH = "ADD_HEALTH",
    TIME_SLOW = "TIME_SLOW",
    X3_DAMAGE = "X3_DAMAGE",
    -- JETPACK = "JETPACK",
    INFINITE_AMMO = "INFINITE_AMMO"
}

class("Perk").extends()
function Perk:init(durationSeconds, perkValue)
    Perk.super.init(self)

    self.durationSeconds = durationSeconds
    self.startTimeMS = 0
    self.perkValue = perkValue
end

function Perk:setActive()
    self.startTimeMS = playdate.getCurrentTimeMilliseconds()
end

function Perk:isPerkActive()
    if self.startTimeMS == 0 then
        return false
    else
        local timeDiffSeconds = (playdate.getCurrentTimeMilliseconds() - self.startTimeMS) / 1000
        printDebug("perk time diff = " .. timeDiffSeconds, DEBUG)
        if timeDiffSeconds < self.durationSeconds then
            return true
        else
            return false
        end
    end
end

PERKS = {
    INVINCIBLE = Perk(15, 0),
    ADD_HEALTH = Perk(15, 20),
    TIME_SLOW = Perk(15, 5),
    X3_DAMAGE = Perk(15, 3),
    INFINITE_AMMO = Perk(15, 0)
}
-- function isPerkActive(perkName)
--     if not PERKS[perkName] then
--         printDebug("perk doesnt exist", DEBUG)
--         return false
--     elseif PERKS[perkName].startTimeMS == 0 then
--         printDebug("perk not initialized", DEBUG)
--         return false
--     else
--         local timeDiffSeconds = (playdate.getCurrentTimeMilliseconds() - PERKS[perkName].startTimeMS) / 1000
--         printDebug("perk time diff = " .. timeDiffSeconds, DEBUG)
--         if PERKS[perkName].durationSeconds < timeDiffSeconds then
--             return true
--         else
--             return false
--         end
--     end
-- end