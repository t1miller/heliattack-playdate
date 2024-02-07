import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

import 'utils'


local gfx<const> = playdate.graphics

local DEBUG <const> = true
local DIALOG_Z <const> = 10000
local DIALOG_STATE <const> = {
    SHOWING = "0",
    NOT_SHOWING = "1"
}

class('Dialog').extends(gfx.sprite)

function Dialog:init(x, y, width, height, title, description, buttonText)
    Dialog.super.init(self)

    self.width = width or 260
    self.height = height or 170
    self.title = title or "title"
    self.description = description or "description"
    self.buttonText = buttonText or "press me"

    self.state = DIALOG_STATE.NOT_SHOWING
    self.titleFont = gfx.font.new("fonts/Roobert-24-Medium")
    self.buttonFont =  gfx.font.new("fonts/Roobert-11-Bold")
    self.descriptionFont = gfx.font.new("fonts/Roobert-11-Medium")
    self.titleAlignment = kTextAlignment.center
    self.buttonAlignment = kTextAlignment.left
    self.descriptionAlignment = kTextAlignment.center
    self.titleX = self.width/2
    self.titleY = 10
    self.descriptionX = self.width/2
    self.descriptionY = 60
    self.buttonX = 70
    self.buttonY = 110


    self.dialogBoxInputHandler = {AButtonDown = function () end, BButtonDown = function () end}

    self:setIgnoresDrawOffset(true)
    self:setSize(self.width, self.height)
    self:moveTo(x, y)
    self:setZIndex(DIALOG_Z)
end

function Dialog:setButtonCallbacks(aButtonCallback, bButtonCallback)
    self.dialogBoxInputHandler = {
        AButtonDown = function ()
            if aButtonCallback then
                aButtonCallback()
            end
        end,

		BButtonDown = function ()
            if bButtonCallback then
                bButtonCallback()
            end
		end,
	}
end

function Dialog:setDescription(description)
    self.description = description
end

function Dialog:draw()

    gfx.pushContext()

        -- draw the box
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(0, 0, self.width, self.height)

        -- border
        gfx.setLineWidth(4)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawRect(0, 0, self.width, self.height)

        -- buttons
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.setFont(self.buttonFont)
        gfx.drawTextAligned(self.buttonText, self.buttonX, self.buttonY, self.buttonAlignment)

        -- title
        gfx.setFont(self.titleFont)
        gfx.drawTextAligned(self.title, self.titleX, self.titleY, self.titleAlignment)

        -- description
        gfx.setFont(self.descriptionFont)
        gfx.drawTextAligned(self.description,  self.descriptionX, self.descriptionY, self.descriptionAlignment)

    gfx.popContext()
end


function Dialog:show()
    if self:isShowing() then
        self:dismiss()
    end
    self.state = DIALOG_STATE.SHOWING
    self:add()

    playdate.inputHandlers.push(self.dialogBoxInputHandler)
    printDebug("Dialog: show() title="..self.title.." description="..self.description.." buttonText="..self.buttonText, DEBUG)
end

function Dialog:isShowing()
    return self.state == DIALOG_STATE.SHOWING
end

function Dialog:dismiss()
    if self:isShowing() == false then
        return
    end

    self.state = DIALOG_STATE.NOT_SHOWING
    self:remove()

    playdate.inputHandlers.pop()
    printDebug("Dialog Box: dismissing", DEBUG)
end
