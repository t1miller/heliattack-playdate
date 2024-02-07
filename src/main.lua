import "CoreLibs/crank"
import "CoreLibs/timer"
import "CoreLibs/sprites"
import "CoreLibs/graphics"
import 'CoreLibs/frameTimer'
import 'CoreLibs/easing'

import 'utils'
import 'game'

playdate.display.setRefreshRate(30)
local spriteUpdate <const> = playdate.graphics.sprite.update
local frametimerUpdate <const> = playdate.frameTimer.updateTimers
local timerUpdate <const> = playdate.timer.updateTimers

local game = Game()

function playdate.update()
    spriteUpdate()
    frametimerUpdate()
    timerUpdate()
    playdate.drawFPS(0, 0)
end


function playdate.gameWillTerminate()
end


function playdate.deviceWillSleep()
end