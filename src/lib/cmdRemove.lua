local properprint = require("lib.properprint")
local files = require("lib.ccpt.files")
local ccpthelper = require("lib.ccpt.helper")
local update = require("lib.ccpt.cmdUpdate")
-- Remove
--[[  Remove Package URL from local list
]]--
local function remove(state)
	-- Check input
	if state.args[2] == nil then
		properprint.pprint("Incomplete command, missing: 'Package ID'; Syntax: 'ccpt remove <PackageID>'")
		return
	end
	local custompackages = files.readData("/.ccpt/custompackages",true)
	if custompackages[state.args[2]]==nil then
		properprint.pprint("A custom package with the id '" .. state.args[2] .. "' does not exist!")
		return
	end
	-- Really wanna do that?
	properprint.pprint("Do you want to remove the custom package '" .. state.args[2] .. "'? There is no undo. [y/n]:")
	if not ccpthelper.ynchoice() then
		properprint.pprint("Canceled. No action was taken.")
		return
	end
	-- Remove entry from custompackages file
	custompackages[state.args[2]] = nil
	files.storeData("/.ccpt/custompackages",custompackages)
	properprint.pprint("Custom package successfully removed!")
	-- Update packagedata?
	properprint.pprint("Do you want to update the package data ('cctp update')? Your custom package will still be able to be installed/updated/uninstalled until updating. [y/n]:")
	if ccpthelper.ynchoice() then
		update()
	end
end
return remove