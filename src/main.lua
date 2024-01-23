import "CoreLibs/crank"
import "CoreLibs/timer"
import "CoreLibs/sprites"
import "CoreLibs/graphics"
import 'CoreLibs/frameTimer'
import 'CoreLibs/easing'

import 'game'

playdate.display.setRefreshRate(30)
local spriteUpdate <const> = playdate.graphics.sprite.update
local frametimerUpdate = playdate.frameTimer.updateTimers
local timerUpdate = playdate.timer.updateTimers
-- local gfx = playdate.graphics

local game = Game()


function playdate.update()
    spriteUpdate()
    frametimerUpdate()
    timerUpdate()
end


function playdate.gameWillTerminate()
end


function playdate.deviceWillSleep()
end