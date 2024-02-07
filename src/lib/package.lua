local ccptPackage = {}

--requires
local properprint = require("lib.properprint")
local files = require("lib.ccpt.files")
local web = require("lib.ccpt.web")
local ccpthelper = require("lib.ccpt.helper")



-- PACKAGE FUNCTIONS --
--[[ Checks wether a package is installed
	@param String packageid: The ID of the package
	@return boolean installed: Is the package installed?
]]--
local function isinstalled(packageid)
	return not (files.readData("/.ccpt/installedpackages",true)[packageid] == nil)
end
ccptPackage.isinstalled = isinstalled

--[[ Checks wether a package is installed
	@param String packageid: The ID of the package
	@return Table|boolean packagedata|error: Read the data of the package from '/.ccpt/packagedata'; If package is not found return false
]]--
local function getpackagedata(packageid)
	-- Read package data
	local allpackagedata = files.readData("/.ccpt/packagedata",false)
	-- Is the package data built yet?
	if allpackagedata==false then
		properprint.pprint("Package Date is not yet built. Please execute 'ccpt update' first. If this message still apears, thats a bug, please report.")
		return false
	end
	local packagedata = allpackagedata[packageid]
	-- Does the package exist?
	if packagedata==nil then
		properprint.pprint("No data about package '" .. packageid .. "' availible. If you've spelled everything correctly, try executing 'ccpt update'")
		return false
	end
	-- Is the package installed?
	local installedversion = files.readData("/.ccpt/installedpackages",true)[packageid]
	if not (installedversion==nil) then
		packagedata["status"] = "installed"
		packagedata["installedversion"] = installedversion
	else
		packagedata["status"] = "not installed"
	end
	return packagedata
end
ccptPackage.getpackagedata = getpackagedata

--[[ Searches all packages for updates
	@param Table|nil installedpackages|nil: installedpackages to prevent fetching them again; If nil they are fetched again
	@param boolean|nil reducedprint|nil: If reducedprint is true, only if updates are availible only the result is printed in console, but nothing else. If nil, false is taken as default.
	@result Table packageswithupdates: Table with packages with updates is returned
]]--
local function checkforupdates(installedpackages,reducedprint)
	-- If parameters are nil, load defaults
	reducedprint = reducedprint or false
	installedpackages = installedpackages or files.readData("/.ccpt/installedpackages",true)
	
	ccpthelper.bprint("Checking for updates...",reducedprint)
	
	-- Check for updates
	local packageswithupdates = {}
	for k,v in pairs(installedpackages) do
		if getpackagedata(k)["newestversion"] > v then
			packageswithupdates[#packageswithupdates+1] = k
		end
	end
	
	-- Print result
	if #packageswithupdates==0 then
		ccpthelper.bprint("All installed packages are up to date!",reducedprint)
	elseif #packageswithupdates==1 then
		print("There is 1 package with a newer version availible: " .. ccpthelper.arraytostring(packageswithupdates))
	else
		print("There are " .. #packageswithupdates .." packages with a newer version availible: " .. ccpthelper.arraytostring(packageswithupdates))
	end
	
	return packageswithupdates
end
ccptPackage.checkforupdates = checkforupdates
return ccptPackage