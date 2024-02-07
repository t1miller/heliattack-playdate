import 'CoreLibs/easing'
import 'CoreLibs/timer'

local gfx = playdate.graphics

-- TODO
-- it makes sense to cache gun images here

-- if adding a new gun type add it to
-- GUN_NAMES, GUN_TYPE, AMMO_TYPE
GUN_NAMES = {
    ABOMB = "ABOMB",
    RPG = "RPG",
    GRENADE = "GRENADE",
    RAIL = "RAIL",
    SPEAR = "SPEAR",
    UZI = "UZI",
    -- todo
    MACHINE_GUN = "MACHINE_GUN",
    MINI_GUN = "MINI_GUN",
    SHOTGUN = "SHOTGUN",
}

GUN_TYPE = {
    ABOMB = {
        imgTable = "images/guns/abombgun",
        xOffsetFixed = -1,
        yOffsetFixed = -5,
        xOffset = 2,
        yOffset = 3,
        ammo = 3,
        reloadTime = 5,
        framesIdleReloaded = 1,
        framesIdleReloadedFlipped = 8,
        framesIdleNotReloaded = 7,
        framesIdleNotReloadedFlipped = 14,
        framesNormal = {1,1,2,2,3,3,4,4,5,5,6,6,7,7},
        framesFlipped = {8,8,9,9,10,10,11,11,12,12,13,13,14,14},
        tag = "abombgun",
        ammoType="ABOMB"
    },
    RPG = {
        imgTable = "images/guns/bazooka",
        xOffsetFixed = 0,
        yOffsetFixed = -5,
        xOffset = -5,
        yOffset = 0,
        ammo = 6,
        reloadTime = 1.5,
        framesIdleReloaded = 1,
        framesIdleReloadedFlipped = 8,
        framesIdleNotReloaded = 7,
        framesIdleNotReloadedFlipped = 14,
        framesNormal = {1,1,2,2,3,3,4,4,5,5,6,6,7,7},
        framesFlipped = {8,8,9,9,10,10,11,11,12,12,13,13,14,14},
        tag = "bazookagun",
        ammoType="RPG"
    },
    GRENADE = {
        imgTable = "images/guns/grenadelauncher",
        xOffsetFixed = 0,
        yOffsetFixed = -10,
        xOffset = 0,
        yOffset = 0,
        ammo = 6,
        reloadTime = 1,
        framesIdleReloaded = 1,
        framesIdleReloadedFlipped = 8,
        framesIdleNotReloaded = 7,
        framesIdleNotReloadedFlipped = 14,
        framesNormal = {1,1,2,2,3,3,4,4,5,5,6,6,7,7},
        framesFlipped = {8,8,9,9,10,10,11,11,12,12,13,13,14,14},
        tag = "grenadlauncher",
        ammoType="GRENADE"
    },
    RAIL = {
        imgTable = "images/guns/railgun",
        xOffsetFixed = 0,
        yOffsetFixed = -5,
        xOffset = 10,
        yOffset = 10,
        ammo = 3,
        reloadTime = 2,
        framesIdleReloaded = 1,
        framesIdleReloadedFlipped = 8,
        framesIdleNotReloaded = 7,
        framesIdleNotReloadedFlipped = 14,
        framesNormal = {1,1,2,2,3,3,4,4,5,5,6,6,7,7},
        framesFlipped = {8,8,9,9,10,10,11,11,12,12,13,13,14,14},
        tag = "railgun",
        ammoType="RAIL"
    },
    SPEAR = {
        imgTable = "images/guns/speargun",
        xOffsetFixed = 0,
        yOffsetFixed = -10,
        xOffset = 5,
        yOffset = 3,
        ammo = 3,
        reloadTime = 2,
        framesIdleReloaded = 1,
        framesIdleReloadedFlipped = 8,
        framesIdleNotReloaded = 7,
        framesIdleNotReloadedFlipped = 14,
        framesNormal = {1,2,3,4,5,6,7},
        framesFlipped = {8,9,10,11,12,13,14},
        tag = "speargun",
        ammoType="SPEAR"
    },
    MACHINE_GUN = {
        imgTable = "images/guns/machinegun",
        xOffsetFixed = 0,
        yOffsetFixed = -7,
        xOffset = 5,
        yOffset = 2,
        ammo = 10000000,
        reloadTime = .2,
        framesIdleReloaded = 1,
        framesIdleReloadedFlipped = 8,
        framesIdleNotReloaded = 7,
        framesIdleNotReloadedFlipped = 14,
        framesNormal = {1,2,3,4,5,6,7},
        framesFlipped = {8,9,10,11,12,13,14},
        tag = "machinegun",
        ammoType="MACHINEGUN_BULLET"
    },
    SHOTGUN = {
        imgTable = "images/guns/shotgun",
        xOffsetFixed = 0,
        yOffsetFixed = -7,
        xOffset = 5,
        yOffset = 2,
        ammo = 10,
        reloadTime = 1.5,
        framesIdleReloaded = 1,
        framesIdleReloadedFlipped = 8,
        framesIdleNotReloaded = 7,
        framesIdleNotReloadedFlipped = 14,
        framesNormal = {1,2,2,3,3,4,5,5,6,6,7},
        framesFlipped = {8,9,9,10,10,11,12,12,13,13,14},
        tag = "shotgun",
        ammoType="SHOTGUN_BULLET"
    },
    UZI = {
        imgTable = "images/guns/uzi",
        xOffsetFixed = 0,
        yOffsetFixed = -7,
        xOffset = 5,
        yOffset = 2,
        ammo = 100,
        reloadTime = .05,
        framesIdleReloaded = 1,
        framesIdleReloadedFlipped = 8,
        framesIdleNotReloaded = 7,
        framesIdleNotReloadedFlipped = 14,
        framesNormal = {1,2,3,4,5,6,7},
        framesFlipped = {8,9,10,11,12,13,14},
        tag = "uzi",
        ammoType="UZI_BULLET"
    }
}


AMMO_TYPE = {
    ABOMB = {
        imgTable = gfx.imagetable.new("images/guns/abomb"),
        xOffset = 30,
        yOffset = 30,
        damage = 100,
        frames = {1,1,2,2,3,3,4,4,5,5,6,6},
        useCollideRect = true,
        easingFunctionFrameDuration = 50,
        easingFunctionStartValue = 0,
        easingFunctionEndValue = 2,
        easingFunctionType = playdate.easingFunctions.inSine
    },
    GRENADE = {
        imgTable = gfx.imagetable.new("images/guns/grenade"),
        xOffset = 30,
        yOffset = 30,
        damage = 25,
        frames = {
            3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,6,
            1,1,1,2,2,2,1,1,1,1,
            3,3,4,4,5,5,6,6,3,3,4,4,5,5,6,6,3,3,4,4,5,5,6,6,3,3,4,4,5,5,6,6,
            3,3,4,4,5,5,6,6,3,3,4,4,5,5,6,6,3,3,4,4,5,5,6,6,3,3,4,4,5,5,6,6,
            3,3,4,4,5,5,6,6,3,3,4,4,5,5,6,6,3,3,4,4,5,5,6,6,3,3,4,4,5,5,6,6,
        },
        useCollideRect = true,
        easingFunctionFrameDuration = 40,
        easingFunctionStartValue = 0,
        easingFunctionEndValue = 40,
        easingFunctionType = playdate.easingFunctions.inCubic,
    },
    RPG = {
        imgTable = gfx.imagetable.new("images/guns/rocket"),
        xOffset = 30,
        yOffset = 30,
        damage = 33,
        frames = {1,1,2,2,3,3,4,4,5,5,6,6},
        useCollideRect = true,
        easingFunctionFrameDuration = 50,
        easingFunctionStartValue = 3,
        easingFunctionEndValue = 30,
        easingFunctionType = playdate.easingFunctions.linear,
    },
    -- bullet is different than projectiles and has its own class
    MACHINEGUN_BULLET = {
        xOffset = 30,
        yOffset = 30,
        damage = 2,
        speed = 7,
        peletsPerShot = 1,
        isPlayerShooting = true,
    },
    MINIGUN_BULLET = {
        xOffset = 30,
        yOffset = 30,
        damage = 5,
        -- damage = 50,
        speed = 2,
        peletsPerShot = 1,
        isPlayerShooting = false,
    },
    SHOTGUN_BULLET = {
        xOffset = 30,
        yOffset = 30,
        damage = 4,
        speed = 5,
        peletsPerShot = 12,
        isPlayerShooting = true,
    },
    UZI_BULLET = {
        xOffset = 30,
        yOffset = 30,
        damage = 4,
        speed = 7,
        peletsPerShot = 1,
        isPlayerShooting = true,
    },
    SPEAR = {
        imgTable = gfx.image.new("images/guns/spear"),
        xOffset = 40,
        yOffset = 30,
        damage = 100,
        -- Spear is only type with pre-created easing function because of how
        -- unique it is
        easingFunction = playdate.frameTimer.new(5, 0, 8, playdate.easingFunctions.linear)
    },
    RAIL = {
        PROJECTILE = {
            imgTable = gfx.imagetable.new("images/guns/rail"),
            xOffset = 220,
            yOffset = 220,
            damage = 55,
            frames = {1,1,2,2},
            useCollideRect = false,
            timeToKill = .5,
            easingFunctionFrameDuration = 6,
            easingFunctionStartValue = 0,
            easingFunctionEndValue = 0,
            easingFunctionType = playdate.easingFunctions.inQuint
        },
        BULLET = {
            xOffset = 30,
            yOffset = 30,
            damage = 55,
            speed = 100,
            peletsPerShot = 1,
            width = 8,
            height = 8,
            color = gfx.kColorWhite,
            isPlayerShooting = true,
        }
    },

}

function deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
