-- COMMAND FUNCTIONS --
local command = {}

command.add = require("lib.ccpt.cmdAdd")
command.infor = require("lib.ccpt.cmdInfo")
command.install = require("lib.ccpt.cmdInstall")
command.list = require("lib.ccpt.cmdList")
command.remove = require("lib.ccpt.cmdRemove")
command.uninstall = require("lib.ccpt.cmdUninstall")
command.update = require("lib.ccpt.cmdUpdate")
command.upgrade = require("lib.ccpt.cmdUpgrade")


--functions that didn't fit as their own file
local properprint = require("lib.properprint")
local files = require("lib.ccpt.files")
local data = require("lib.ccpt.data")
-- Startup
--[[ Run on Startup
]]--
local function startup()
	-- Update silently on startup
	command.update(true)
end
command.startup = startup

-- Help
--[[ Print help
]]--
local function help()
	print("Syntax: ccpt")
	for i,v in pairs(data.actions) do
		if (not (v["comment"] == nil)) then
			properprint.pprint(i .. ": " .. v["comment"],5)
		end
	end
	print("")
	print("This package tool has Super Creeper Powers.")
end
command.help = help

-- Version
--[[ Print Version
]]--
local function version()
	-- Count lines
	local linecount = 0
	for _ in io.lines'ccpt' do
		linecount = linecount + 1
	end
	-- Print version
	properprint.pprint("ComputerCraft Package Tool")
	properprint.pprint("by PentagonLP")
	properprint.pprint("Version: 1.0")
	properprint.pprint(linecount .. " lines of code containing " .. #files.readFile("ccpt",nil) .. " Characters.")
end
command.version = version

-- Idk randomly appeared one day  (I'm not sure if this is actually used, but I'm not going to remove it just in case -hpf3)
--[[ Fuse
]]--
local function zzzzzz()
	properprint.pprint("The 'ohnosecond':")
	properprint.pprint("The 'ohnosecond' is the fraction of time between making a mistake and realizing it.")
	properprint.pprint("(Oh, and please fix the hole you've created)")
end
command.zzzzzz = zzzzzz

--[[ Explode
]]--
local function boom()
	print("|--------------|")
	print("| |-|      |-| |")
	print("|    |----|    |")
	print("|  |--------|  |")
	print("|  |--------|  |")
	print("|  |-      -|  |")
	print("|--------------|")
	print("....\"Have you exploded today?\"...")
end
command.boom = boom

return command