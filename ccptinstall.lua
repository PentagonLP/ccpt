--[[
	ComputerCraft Package Tool Installer
	Author: PentagonLP
	Version: 1.0
	Lines of Code: 161; Characters: 5541
]]

-- Read arguments
local args = { ... }

-- FILE MANIPULATION FUNCTIONS --
--[[ Checks if file exists
	@param String filepath: Filepath to check
	@return boolean: Does the file exist?
--]]
local function file_exists(filepath)
	local f = io.open(filepath, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

--[[ Stores a file in a desired location
	@param String filepath: Filepath where to create file (if file already exists, it gets overwritten)
	@param String content: Content to store in file
--]]
local function storeFile(filepath, content)
	local writefile = fs.open(filepath, "w")
	writefile.write(content)
	writefile.close()
end

--[[ Reads a file from a desired location
	@param String filepath: Filepath to the file to read
	@param String createnew: (Optional) Content to store in new file and return if file does not exist. Can be nil.
	@return String|boolean content|error: Content of the file; If createnew is nil and file doesn't exist boolean false is returned
--]]
local function readFile(filepath, createnew)
	local readfile = fs.open(filepath, "r")
	if readfile == nil then
		if not (createnew == nil) then
			storeFile(filepath, createnew)
			return createnew
		else
			return false
		end
	end
	local content = readfile.readAll()
	readfile.close()
	return content
end

--[[ Stores a table in a file
	@param String filepath: Filepath where to create file (if file already exists, it gets overwritten)
	@param Table data: Table to store in file
--]]
local function storeData(filepath, data)
	storeFile(filepath, textutils.serializeJSON(data):gsub("\n", ""))
end

--[[ Reads a table from a file in a desired location
	@param String filepath: Filepath to the file to read
	@param boolean createnew: If true, an empty table is stored in new file and returned if file does not exist.
	@return Table|boolean content|error: Table thats stored in the file; If createnew is false and file doesn't exist boolean false is returned
--]]
local function readData(filepath, createnew)
	if createnew then
		return textutils.unserializeJSON(readFile(filepath, textutils.serializeJSON({}):gsub("\n", "")))
	else
		return textutils.unserializeJSON(readFile(filepath, nil))
	end
end

-- HTTP FETCH FUNCTIONS --
--[[ Gets result of HTTP URL
	@param String url: The desired URL
	@return Table|boolean result|error: The result of the request; If the URL is not reachable, an error is printed in the terminal and boolean false is returned
--]]
local function gethttpresult(url)
	if not http.checkURL(url) then
		print("ERROR: Url '" .. url .. "' is blocked in config. Unable to fetch data.")
		return false
	end
	local result = http.get(url)
	if result == nil then
		print("ERROR: Unable to reach '" .. url .. "'")
		return false
	end
	return result
end

--[[ Download file HTTP URL
	@param String filepath: Filepath where to create file (if file already exists, it gets overwritten)
	@param String url: The desired URL
	@return nil|boolean nil|error: nil; If the URL is not reachable, an error is printed in the terminal and boolean false is returned
--]]
local function downloadfile(filepath, url)
	local result = gethttpresult(url)
	if result == false then
		return false
	end
	storeFile(filepath, result.readAll())
end

-- MISC HELPER FUNCTIONS --
--[[ Checks wether a String starts with another one
	@param String haystack: String to check wether is starts with another one
	@param String needle: String to check wether another one starts with it
	@return boolean result: Wether the firest String starts with the second one
]]
   --
local function startsWith(haystack, needle)
	return string.sub(haystack, 1, string.len(needle)) == needle
end

-- Github Functions --
--[[ Gets the contents of the lib directory
	@return Table|boolean contents|error: The contents of the lib directory; If the URL is not reachable, an error is printed in the terminal and boolean false is returned]]
local function GetDirContents()
	local contents = gethttpresult("https://api.github.com/repos/hpf3/ccpt/contents/src/lib")
	if contents == false then
		return false
	end
	return textutils.unserializeJSON(contents.readAll())
end

--[[ Downloads all files in the lib directory
	@return boolean result: Wether the download was successful
]]
   --
local function GetLibs()
	local contents = GetDirContents()
	if contents == false then
		return false
	end
	local libs = {}
	for i = 1, #contents do
		if contents[i]["type"] == "file" then
			if downloadfile("/lib/ccpt/" .. contents[i]["name"], contents[i]["download_url"]) == false then
				return false
			end
		end
	end
	return true
end
-- MAIN PROGRAMM --
if (args[1] == "install") or (args[1] == nil) then
	print("[Installer] Well, hello there!")
	print("[Installer] Thank you for downloading the ComputerCraft Package Tool! Installing...")
	print("[Installer] Installing 'properprint' library...")
	if downloadfile("/lib/properprint", "https://raw.githubusercontent.com/hpf3/properprint/main/properprint") == false then
		return false
	end
	print("[Installer] Successfully installed 'properprint'!")
	print("[Installer] Installing 'ccpt'...")
	if downloadfile("ccpt", "https://raw.githubusercontent.com/hpf3/ccpt/main/ccpt") == false then
		return false
	end
	if GetLibs() == false then
		return false
	end
	print("[Installer] Successfully installed 'ccpt'!")
	print("[Installer] Running 'ccpt update'...")
	shell.run("ccpt", "update")
	print("[Installer] Reading package data...")
	local packagedata = readData("/.ccpt/packagedata")
	print("[Installer] Storing installed packages...")
	storeData("/.ccpt/installedpackages", {
		ccpt = packagedata["ccpt"]["newestversion"],
		pprint = packagedata["pprint"]["newestversion"]
	})
	print("[Installer] 'ccpt' successfully installed!")
elseif args[1] == "update" then
	print("[Installer] Updating 'ccpt'...")
	if downloadfile("ccpt", "https://raw.githubusercontent.com/hpf3/ccpt/main/ccpt") == false then
		return false
	end
	if GetLibs() == false then
		return false
	end
elseif args[1] == "remove" then
	print("[Installer] Uninstalling 'ccpt'...")
	fs.delete("/ccpt")
	fs.delete("/.ccpt")
	fs.delete("/lib/ccpt")
	shell.setCompletionFunction("ccpt", nil)
	if file_exists("startup") then
		local startup = readFile("startup", "")
		if startsWith(startup, "-- ccpt: Seach for updates\nshell.run(\"ccpt\",\"startup\")") then
			print("[Installer] Removing 'ccpt' from startup...")
			-- i miss c#'s strict typing
---@diagnostic disable-next-line: param-type-mismatch
			storeFile("startup", string.sub(startup, 56))
		end
	end
	print("[Installer] So long, and thanks for all the fish!")
else
	print("[Installer] Invalid argument: " .. args[1])
end
