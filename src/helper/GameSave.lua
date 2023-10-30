import 'helper/Utils'

GAME_SAVE_KEYS = {
    BoardGrid = "saved data for board",
    MoveGrid = "saved data for move grid",
    ChessGame = "saved data for chessgame"
}

local store <const> = playdate.datastore
local DEBUG <const> = true

class("GameSave").extends()

function GameSave:init()
    GameSave.super.init(self)
    self.gameSave = {}
    self:load()
end

function GameSave:delete()
    local result = store.delete("gameSave")
    self.gameSave = {}
    printDebug("GameSave: file deleted = "..tostring(result), DEBUG)
end

function GameSave:getSize()
    local fileSize = playdate.file.getSize("gameSave.json")
    printDebug("GameSave: file size = "..tostring(fileSize), DEBUG)
    return fileSize
end

function GameSave:exists()
    return playdate.file.exists("gameSave.json")
end

function GameSave:put(k,v)
    printDebug("GameSave: putting key="..k, DEBUG)
    self.gameSave[k] = v
end

function GameSave:get(k)
    printDebug("GameSave: get key="..k, DEBUG)
    if self.gameSave[k] then
        return self.gameSave[k]
    end
    printDebug("GameSave: error key doesnt exist", DEBUG)
    return nil
end
-- load all saved tables into object
-- save game state when app is about to exit
function GameSave:save()
    playdate.resetElapsedTime()
    local success = store.write(self.gameSave, "gameSave", false)
    printDebug("GameSave: saving gameSave file="..tostring(success).." took "..playdate.getElapsedTime().." seconds", DEBUG)
end

-- function GameSave:saveAfterDelay()
--     runAfterDelay(2000, self.save)
-- end

function GameSave:load()
    playdate.resetElapsedTime()
	local gameSaveFile = store.read("gameSave")
    printDebug("GameSave: game save file took "..playdate.getElapsedTime().." seconds to load", DEBUG)
    if gameSaveFile == nil then
        printDebug("GameSave: error loading gameSave file", DEBUG)
        return
    end
    self.gameSave = gameSaveFile
    printDebug("GameSave: loaded gameSave file", DEBUG)
end

