local properprint = require("lib.properprint")
local files = require("lib.ccpt.files")
local web = require("lib.ccpt.web")
local ccptPackage = require("lib.ccpt.package")
local cmdUpgrade = require("lib.ccpt.cmdUpgrade")
local data = require("lib.ccpt.data")

-- Install
local functions = {}
--[[ Recursive function to install Packages and dependencies
]]--
local function installpackage(packageid,packageinfo)
	properprint.pprint("Installing '" .. packageid .. "'...")
	-- Get Packageinfo
	if (packageinfo==nil) then
		print("Reading packageinfo of '" .. packageid .. "'...")
		packageinfo = ccptPackage.getpackagedata(packageid)
		if packageinfo==false then
			return false
		end
	end
	
	-- Install dependencies
	properprint.pprint("Installing dependencies of '" .. packageid .. "', if there are any...")
	for k,v in pairs(packageinfo["dependencies"]) do
		local installedpackages = files.readData("/.ccpt/installedpackages",true)
		if installedpackages[k] == nil then
			if installpackage(k,nil)==false then
				return false
			end
		elseif installedpackages[k] < v then
			if cmdUpgrade.upgradepackage(k,nil)==false then
				return false
			end
		end
	end
	local installed = 0
	-- Install package
	print("Installing '" .. packageid .. "'...")
	local installdata = packageinfo["install"]
	local result = data.installtypes[installdata["type"]]["install"](installdata)
	if result==false then
		return false
	end
	local installedpackages = files.readData("/.ccpt/installedpackages",true)
	installedpackages[packageid] = packageinfo["newestversion"]
	files.storeData("/.ccpt/installedpackages",installedpackages)
	print("'" .. packageid .. "' successfully installed!")
	installed = installed+1
end
functions.installpackage = installpackage

--[[ Different install methodes
]]--
local function installlibrary(installdata)
	local result = web.downloadfile("lib/" .. installdata["filename"],installdata["url"])
	if result==false then
		return false
	end
end
functions.installlibrary = installlibrary

local function installscript(installdata)
	local result = web.downloadfile("/.ccpt/tempinstaller",installdata["scripturl"])
	if result==false then
		return false
	end
	shell.run("/.ccpt/tempinstaller","install")
	fs.delete("/.ccpt/tempinstaller")
end
functions.installscript = installscript

--[[ Install a Package 
]]--
local function install(state)
	if state.args[2] == nil then
		properprint.pprint("Incomplete command, missing: 'Package ID'; Syntax: 'ccpt install <PackageID>'")
		return
	end
	local packageinfo = ccptPackage.getpackagedata(state.args[2])
	if packageinfo == false then
		return
	end
	if packageinfo["status"] == "installed" then
		properprint.pprint("Package '" .. state.args[2] .. "' is already installed.")
		return
	end
	-- Ok, all clear, lets get installing!
	local result = installpackage(state.args[2],packageinfo)
	if result==false then
		return
	end
	print("Install of '" .. state.args[2] .. "' complete!")
end
functions.install = install
return functions