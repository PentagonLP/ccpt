--requires
local properprint = require("lib.properprint")
local files = require("lib.ccpt.files")


-- List
--[[ List all Packages 
]]--
local function list()
	-- Read data
	print("Reading all packages data...")
	if not files.file_exists("/.ccpt/packagedata") then
		properprint.pprint("No Packages found. Please run 'cctp update' first.'")
		return
	end
	local packagedata = files.readData("/.ccpt/packagedata",true)
	print("Reading Installed packages...")
	local installedpackages = files.readData("/.ccpt/installedpackages",true)
	-- Print list
	properprint.pprint("List of all known Packages:")
    local updateinfo = ""
	for k,v in pairs(installedpackages) do
		if packagedata[k]["newestversion"] > v then
			updateinfo = "outdated"
		else
			updateinfo = "up to date"
		end
		properprint.pprint(k .. " (installed, " .. updateinfo .. ")",2)
	end
	for k,v in pairs(packagedata) do
		if installedpackages[k] == nil then
			properprint.pprint(k .. " (not installed)",2)
		end
	end
end
return list