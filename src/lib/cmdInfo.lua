--requires
local properprint = require("lib.properprint")
local ccptPackage = require("lib.ccpt.package")
local data = require("lib.ccpt.data")
-- Info
--[[ Info about a package
]]--
local function info(state)
	-- Check input
	if state.args[2] == nil then
		properprint.pprint("Incomplete command, missing: 'Package ID'; Syntax: 'ccpt info <PackageID>'")
		return
	end
	-- Get packagedata
	local packageinfo = ccptPackage.getpackagedata(state.args[2])
	if packageinfo == false then
		return
	end
	-- Print packagedata
	properprint.pprint(packageinfo["name"] .. " by " .. packageinfo["author"])
	properprint.pprint(packageinfo["comment"])
	if not (packageinfo["website"]==nil) then
		properprint.pprint("Website: " .. packageinfo["website"])
	end
	properprint.pprint("Installation Type: " .. data.installtypes[packageinfo["install"]["type"]]["desc"])
	if packageinfo["status"]=="installed" then
		properprint.pprint("Installed, Version: " .. packageinfo["installedversion"] .. "; Newest Version is " .. packageinfo["newestversion"])
	else
		properprint.pprint("Not installed; Newest Version is " .. packageinfo["newestversion"])
	end
end
return info