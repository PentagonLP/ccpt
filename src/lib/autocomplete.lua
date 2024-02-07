local data = require("lib.ccpt.data")
local files = require("lib.ccpt.files")
local ccpthelper = require("lib.ccpt.helper")
-- TAB AUTOCOMLETE HELPER FUNCTIONS --
--[[ Add Text to result array if it fits
	@param String option: Autocomplete option to check
	@param String texttocomplete: The already typed in text to.. complete...
	@param Table result: Array to add the option to if it passes the check
]]--
local function addtoresultifitfits(option,texttocomplete,result)
	if ccpthelper.startsWith(option,texttocomplete) then
		result[#result+1] = string.sub(option,#texttocomplete+1)
	end
	return result
end

-- Functions to complete different subcommands of a command
-- Complete action (eg. "update" or "list")
local function completeaction(curText)
	local result = {}
	for i,v in pairs(data.actions) do
		if (not (v["comment"] == nil)) then
			result = addtoresultifitfits(i,curText,result)
		end
	end
	return result
end

-- Complete packageid (filter can be nil to display all, "installed" to only recommend installed packages or "not installed" to only recommend not installed packages)
local autocompletepackagecache = {}
local function completepackageid(curText,filterstate)
	local result = {}
	if curText=="" or curText==nil then
		local packagedata = files.readData("/.ccpt/packagedata",false)
		if not packagedata then
			return {}
		end
		autocompletepackagecache = packagedata
	end
	local installedversion = {}
	if not (filterstate==nil) then
		installedversion = files.readData("/.ccpt/installedpackages",true)
	end
---@diagnostic disable-next-line: unused-local
	for i,v in pairs(autocompletepackagecache) do
		if filterstate=="installed" then
			if not (installedversion[i]==nil) then
				result = addtoresultifitfits(i,curText,result)
			end
		elseif filterstate=="not installed" then
			if installedversion[i]==nil then
				result = addtoresultifitfits(i,curText,result)
			end
		else
			result = addtoresultifitfits(i,curText,result)
		end
	end
	return result
end

-- Complete packageid, but only for custom packages, which is much simpler
local function completecustompackageid(curText)
	local result = {}
	local custompackages = files.readData("/.ccpt/custompackages",true)
---@diagnostic disable-next-line: unused-local
	for i,v in pairs(custompackages) do
		result = addtoresultifitfits(i,curText,result)
	end
	return result
end

--[[ Recursive function to go through the 'autocomplete' array and complete commands accordingly
	@param Table lookup: Part of the 'autocomplete' array to look autocomplete up in
	@param String lastText: Numeric array of parameters before the current one
	@param String curText: The already typed in text to.. complete...
	@param int iterator: Last position in the lookup array
	@return Table completeoptions: Availible complete options
]]--
local function tabcompletehelper(lookup,lastText,curText,iterator)
	if lookup[lastText[iterator]]==nil then
		return {}
	end
	if #lastText==iterator then
		return lookup[lastText[iterator]]["func"](curText,unpack(lookup[lastText[iterator]]["funcargs"]))
	elseif lookup[lastText[iterator]]["next"]==nil then
		return {}
	else
		return tabcompletehelper(lookup[lastText[iterator]]["next"],lastText,curText,iterator+1)
	end
end
--[[ Array to store autocomplete information
]]--
local autocomplete = {
	func = completeaction,
	funcargs = {},
	next = {
		install = {
			func = completepackageid,
			funcargs = {"not installed"}
		},
		uninstall = {
			func = completepackageid,
			funcargs = {"installed"}
		},
		remove = {
			func = completecustompackageid,
			funcargs = {}
		},
		info = {
			func = completepackageid,
			funcargs = {}
		}
	}
}

-- MAIN AUTOCOMLETE FUNCTION --
---@diagnostic disable-next-line: unused-local
local function tabcomplete(shell, parNumber, curText, lastText) -- special function param defined by the shell API
	local result = {}
	tabcompletehelper(
		{
			ccpt = autocomplete
		},
	lastText,curText or "",1)
	return result
end
return tabcomplete