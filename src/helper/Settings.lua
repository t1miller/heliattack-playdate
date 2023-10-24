
-- I like to keep my settings keys global and descriptive.
SettingKeys = {
	difficulty = "difficulty"
}

local store = playdate.datastore
local DEBUG <const> = true

class("Settings").extends()

function Settings:init(default_settings)
	Settings.super.init(self)
	self.defaults = default_settings or {}
	self.settings = nil
	self:load()
end

function Settings:set(k, v)
	self.settings[k] = v
end

function Settings:get(k)
	return self.settings[k]
end

function Settings:delete()
	store.delete("settings")
end

function Settings:save()
	printDebug("Settings: saved", DEBUG)
	store.write(self.settings, "settings", true)
end

function Settings:load()
	self.settings = table.deepcopy(self.defaults)
	local current_settings = store.read("settings") or {}
	for k, v in pairs(current_settings) do
		printDebug("Settings: setting "..k.."="..tostring(v), DEBUG)
		self.settings[k] = v
	end
	printTable(self.settings)
	printDebug("Settings: loaded settings", DEBUG)
end
