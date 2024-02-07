local properprint = require("lib.properprint")
local files = require("lib.ccpt.files")
local web = require("lib.ccpt.web")
local ccpthelper = require("lib.ccpt.helper")
local ccptPackage = require("lib.ccpt.package")
local data = require("lib.ccpt.data")


-- Update
--[[ Get packageinfo from the internet and search from updates
	@param boolean startup: Run with startup=true on computer startup; if startup=true it doesn't print as much to the console
]]--
local function update(startup)
	startup = startup or false
	-- Fetch default Packages
	ccpthelper.bprint("Fetching Default Packages...",startup)
	local packages = web.gethttpdata(data.defaultpackageurl)["packages"]
	if packages==false then 
		return
	end
	-- Load custom packages
	ccpthelper.bprint("Reading Custom packages...",startup)
	local custompackages = files.readData("/.ccpt/custompackages",true)
	-- Add Custom Packages to overall package list
	for k,v in pairs(custompackages) do
		packages[k] = v
	end
	
	-- Fetch package data from the diffrent websites
	local packagedata = {}
	for k,v in pairs(packages) do
		ccpthelper.bprint("Downloading package data of '" .. k .. "'...",startup)
		local packageinfo = web.gethttpdata(v)
		if not (packageinfo==false) then
			packagedata[k] = packageinfo
		else
			properprint.pprint("Failed to retrieve data about '" .. k .. "' via '" .. v .. "'. Skipping this package.")
		end
	end
	ccpthelper.bprint("Storing package data of all packages...",startup)
	files.storeData("/.ccpt/packagedata",packagedata)
	-- Read installed packages
	ccpthelper.bprint("Reading Installed Packages...",startup)
	local installedpackages = files.readData("/.ccpt/installedpackages",true)
	local installedpackagesnew = {}
	for k,v in pairs(installedpackages) do
		if packagedata[k]==nil then
			properprint.pprint("Package '" .. k .. "' was removed from the packagelist, but is installed. It will no longer be marked as 'installed', but its files won't be deleted.")
		else
			installedpackagesnew[k] = v
		end
	end
	files.storeData("/.ccpt/installedpackages",installedpackagesnew)
	ccpthelper.bprint("Data update complete!",startup)
	
	-- Check for updates
	ccptPackage.checkforupdates(installedpackagesnew,startup)
end
return update