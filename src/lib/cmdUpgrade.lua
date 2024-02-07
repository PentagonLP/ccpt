local properprint = require("lib.ccpt.properprint")
local files = require("lib.ccpt.files")
local web = require("lib.ccpt.web")
local ccpthelper = require("lib.ccpt.helper")
local ccptPackage = require("lib.ccpt.package")
local data = require("lib.ccpt.data")
local cmdInstall = require("lib.ccpt.cmdInstall")
-- Upgrade
local functions = {}

--[[ Recursive function to update Packages and dependencies
]]--
local function upgradepackage(packageid,packageinfo)
	-- Get Packageinfo
	if (packageinfo==nil) then
		print("Reading packageinfo of '" .. packageid .. "'...")
		packageinfo = ccptPackage.getpackagedata(packageid)
		if packageinfo==false then
			return false
		end
	end
	
	local installedpackages = files.readData("/.ccpt/installedpackages",true)
	if installedpackages[packageid]==packageinfo["newestversion"] then
		properprint.pprint("'" .. packageid .. "' already updated! Skipping... (This is NOT an error)")
		return true
	else
		properprint.pprint("Updating '" .. packageid .. "' (" .. installedpackages[packageid] .. "->" .. packageinfo["newestversion"] .. ")...")
	end
	
	-- Install/Update dependencies
	properprint.pprint("Updating or installing new dependencies of '" .. packageid .. "', if there are any...")
	for k,v in pairs(packageinfo["dependencies"]) do
		local installedpackages = files.readData("/.ccpt/installedpackages",true)
		if installedpackages[k] == nil then
			if cmdInstall.installpackage(k,nil)==false then
				return false
			end
		elseif installedpackages[k] < v then
			if upgradepackage(k,nil)==false then
				return false
			end
		end
	end
	local updated = 0
	-- Install package
	print("Updating '" .. packageid .. "'...")
	local installdata = packageinfo["install"]
	local result = data.installtypes[installdata["type"]]["update"](installdata)
	if result==false then
		return false
	end
	installedpackages = files.readData("/.ccpt/installedpackages",true)
	installedpackages[packageid] = packageinfo["newestversion"]
	files.storeData("/.ccpt/installedpackages",installedpackages)
	print("'" .. packageid .. "' successfully updated!")
	updated = updated+1
end
functions.upgradepackage = upgradepackage
--[[ Different install methodes require different update methodes
]]--
local function updatescript(installdata)
	local result = web.downloadfile("/.ccpt/tempinstaller",installdata["scripturl"])
	if result==false then
		return false
	end
	shell.run("/.ccpt/tempinstaller","update")
	fs.delete("/.ccpt/tempinstaller")
end
functions.updatescript = updatescript

-- Upgrade installed Packages
-- TODO: Single package updates
local function upgrade()
	local packageswithupdates = ccptPackage.checkforupdates(files.readData("/.ccpt/installedpackages",true),false)
	if packageswithupdates==false then
		return
	end
	if #packageswithupdates==0 then
		return
	end
	properprint.pprint("Do you want to update these packages? [y/n]:")
	if not ccpthelper.ynchoice() then
		return
	end
---@diagnostic disable-next-line: unused-local
	for k,v in pairs(packageswithupdates) do
		ccptPackage.upgradepackage(v,nil)
	end
end
functions.upgrade = upgrade
return functions