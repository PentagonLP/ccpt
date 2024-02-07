local properprint = require("properprint")
local files = require("lib.ccpt.files")
local ccpthelper = require("lib.ccpt.helper")
local update = require("lib.ccpt.cmdUpdate")
-- Add
--[[ Add custom package URL to local list
]]--
local function add(state)
	-- Check input
	if state.args[2] == nil then
		properprint.pprint("Incomplete command, missing: 'Package ID'; Syntax: 'ccpt add <PackageID> <PackageinfoURL>'")
		return
	end
	if state.args[3] == nil then
		properprint.pprint("Incomplete command, missing: 'Packageinfo URL'; Syntax: 'ccpt add <PackageID> <PackageinfoURL>'")
		return
	end
	local custompackages = files.readData("/.ccpt/custompackages",true)
	if not (custompackages[state.args[2]]==nil) then
		properprint.pprint("A custom package with the id '" .. state.args[2] .. "' already exists! Please choose a different one.")
		return
	end
	if not files.file_exists("/.ccpt/packagedata") then
		properprint.pprint("Package Date is not yet built. Please execute 'ccpt update' first. If this message still apears, thats a bug, please report.")
	end
	-- Overwrite default packages?
	if not (files.readData("/.ccpt/packagedata",true)[state.args[2]]==nil) then
		properprint.pprint("A package with the id '" .. state.args[2] .. "' already exists! This package will be overwritten if you proceed. Do you want to proceed? [y/n]:")
		if not ccpthelper.ynchoice() then
			return
		end
	end
	-- Add entry in custompackages file
	custompackages[state.args[2]] = state.args[3]
	files.storeData("/.ccpt/custompackages",custompackages)
	properprint.pprint("Custom package successfully added!")
	-- Update packagedata?
	properprint.pprint("Do you want to update the package data ('cctp update')? Your custom package won't be able to be installed until updating. [y/n]:")
	if ccpthelper.ynchoice() then
		update()
	end
end
return add