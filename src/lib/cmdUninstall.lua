local properprint = require("properprint")
local files = require("lib.ccpt.files")
local ccpthelper = require("lib.ccpt.helper")
local ccptPackage = require("lib.ccpt.package")
local web = require("lib.ccpt.web")
local data = require("lib.ccpt.data")

local functions = {}

--[[ Recursive function to find all Packages that are dependend on the one we want to remove to also remove them
]]--
local function getpackagestoremove(packageid,packageinfo,installedpackages,packagestoremove)
	packagestoremove[packageid] = true
	-- Get Packageinfo
	if (packageinfo==nil) then
		print("Reading packageinfo of '" .. packageid .. "'...")
		packageinfo = ccptPackage.getpackagedata(packageid)
		if packageinfo==false then
			return false
		end
	end

	-- Check packages that are dependend on that said package
---@diagnostic disable-next-line: unused-local
	for k,v in pairs(installedpackages) do
		if not (ccptPackage.getpackagedata(k)["dependencies"][packageid]==nil) then
			local packagestoremovenew = getpackagestoremove(k,nil,installedpackages,packagestoremove)
---@diagnostic disable-next-line: param-type-mismatch, unused-local
			for l,w in pairs(packagestoremovenew) do
				packagestoremove[l] = true
			end
		end
	end

	return packagestoremove
end

-- Uninstall
-- Remove installed Packages
local function uninstall(state)
	-- Check input
	if state.args[2] == nil then
		properprint.pprint("Incomplete command, missing: 'Package ID'; Syntax: 'ccpt uninstall <PackageID>'")
		return
	end
	local packageinfo = ccptPackage.getpackagedata(state.args[2])
	if packageinfo == false then
		return
	end
	if packageinfo["status"] == "not installed" then
		properprint.pprint("Package '" .. state.args[2] .. "' is not installed.")
		return
	end
	
	-- Check witch package(s) to remove (A package dependend on a package that's about to get removed is also removed)
	local packagestoremove = getpackagestoremove(state.args[2],packageinfo,files.readData("/.ccpt/installedpackages",true),{})
	local packagestoremovestring = ""
---@diagnostic disable-next-line: param-type-mismatch, unused-local
	for k,v in pairs(packagestoremove) do
		if not (k==state.args[2]) then
			packagestoremovestring = packagestoremovestring .. k .. " "
		end
	end
	
	-- Are you really really REALLY sure to remove these packages?
	if not (#packagestoremovestring==0) then
		properprint.pprint("There are installed packages that depend on the package you want to uninstall: " .. packagestoremovestring)
		properprint.pprint("These packages will be removed if you proceed. Are you sure you want to continue? [y/n]:")
		if ccpthelper.ynchoice() == false then
			return
		end
	else
		properprint.pprint("There are no installed packages that depend on the package you want to uninstall.")
		properprint.pprint("'" .. state.args[2] .. "' will be removed if you proceed. Are you sure you want to continue? [y/n]:")
		if ccpthelper.ynchoice() == false then
			return
		end
	end
	
	-- If cctp would be removed in the process, tell the user that that's a dump idea. But I mean, who am I to stop him, I guess...
---@diagnostic disable-next-line: param-type-mismatch, unused-local
	for k,v in pairs(packagestoremove) do
		if k=="ccpt" then
			if state.args[2] == "ccpt" then
				properprint.pprint("You are about to uninstall the package tool itself. You won't be able to install or uninstall stuff using the tool afterwords (obviously). Are you sure you want to continue? [y/n]:")
			else
				properprint.pprint("You are about to uninstall the package tool itself, because it depends one or more package that is removed. You won't be able to install or uninstall stuff using the tool afterwords (obviously). Are you sure you want to continue? [y/n]:")
			end
			
			if ccpthelper.ynchoice() == false then
				return
			end
			break
		end
	end
	
	-- Uninstall package(s)
    local removed = 0
---@diagnostic disable-next-line: param-type-mismatch, unused-local
	for k,v in pairs(packagestoremove) do
		print("Uninstalling '" .. k .. "'...")
		local installdata = ccptPackage.getpackagedata(k)["install"]
		local result = data.installtypes[installdata["type"]]["remove"](installdata)
		if result==false then
			return false
		end
		local installedpackages = files.readData("/.ccpt/installedpackages",true)
		installedpackages[k] = nil
		files.storeData("/.ccpt/installedpackages",installedpackages)
		print("'" .. k .. "' successfully uninstalled!")
		removed = removed+1
	end
end
functions.uninstall = uninstall


--[[ Different install methodes require different uninstall methodes
]]--
local function removelibrary(installdata)
	fs.delete("lib/" .. installdata["filename"])
end
functions.removelibrary = removelibrary

local function removescript(installdata)
	local result = web.downloadfile("/.ccpt/tempinstaller",installdata["scripturl"])
	if result==false then
		return false
	end
	shell.run("/.ccpt/tempinstaller","remove")
	fs.delete("/.ccpt/tempinstaller")
end
functions.removescript = removescript
return functions