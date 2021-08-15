--[[ 
	ComputerCraft Package Tool Installer
	Author: PentagonLP
	Version: 1.0
	Lines of Code: 161; Characters: 5541
]]

-- Read arguments
local args = {...}

-- FILE MANIPULATION FUNCTIONS --
--[[ Stores a file in a desired location
	@param String filepath: Filepath where to create file (if file already exists, it gets overwritten)
	@param String content: Content to store in file
--]]
local function storeFile(filepath,content)
	local writefile = fs.open(filepath,"w")
	writefile.write(content)
	writefile.close()
end

--[[ Reads a file from a desired location
	@param String filepath: Filepath to the file to read
	@param String createnew: (Optional) Content to store in new file and return if file does not exist. Can be nil.
	@return String|boolean content|error: Content of the file; If createnew is nil and file doesn't exist boolean false is returned
--]]
local function readFile(filepath,createnew)
	local readfile = fs.open(filepath,"r")
	if not then
		if not (createnew==nil) then
			storeFile(filepath,createnew)
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
local function storeData(filepath,data)
	storeFile(filepath,textutils.serialize(data):gsub("\n",""))
end

--[[ Reads a table from a file in a desired location
	@param String filepath: Filepath to the file to read
	@param boolean createnew: If true, an empty table is stored in new file and returned if file does not exist.
	@return Table|boolean content|error: Table thats stored in the file; If createnew is false and file doesn't exist boolean false is returned
--]]
local function readData(filepath,createnew)
	if createnew then
		return textutils.unserialize(readFile(filepath,textutils.serialize({}):gsub("\n","")))
	else
		return textutils.unserialize(readFile(filepath,nil))
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
	local result,err = http.get(url)
	if not result then
		print("ERROR: Unable to reach '" .. url .. "' because '" .. err .. "'")
		return false
	end
	return result
end

--[[ Download file HTTP URL
	@param String filepath: Filepath where to create file (if file already exists, it gets overwritten)
	@param String url: The desired URL
	@return nil|boolean nil|error: nil; If the URL is not reachable, an error is printed in the terminal and boolean false is returned
--]]
local function downloadfile(filepath,url)
	local result = gethttpresult(url)
	if not result then 
		return false
	end
	storeFile(filepath,result.readAll())
end

-- MISC HELPER FUNCTIONS --
--[[ Checks wether a String starts with another one
	@param String haystack: String to check wether is starts with another one
	@param String needle: String to check wether another one starts with it
	@return boolean result: Wether the firest String starts with the second one
]]--
local function startsWith(haystack,needle)
	return string.sub(haystack,1,string.len(needle))==needle
end

-- MAIN PROGRAMM --
if (args[1]=="install") or (args[1]==nil) then
	print("[Installer] Well, hello there!")
	print("[Installer] Thank you for downloading the ComputerCraft Package Tool! Installing...")
	print("[Installer] Installing 'properprint' library...")
	if not downloadfile("lib/properprint","https://raw.githubusercontent.com/PentagonLP/properprint/main/properprint") then
		return false
	end
	print("[Installer] Successfully installed 'properprint'!")
	print("[Installer] Installing 'ccpt'...")
	if not downloadfile("ccpt","https://raw.githubusercontent.com/PentagonLP/ccpt/main/ccpt") then
		return false
	end
	print("[Installer] Successfully installed 'ccpt'!")
	print("[Installer] Running 'ccpt update'...")
	shell.run("ccpt","update")
	print("[Installer] Reading package data...")
	local packagedata = readData("/.ccpt/packagedata")
	print("[Installer] Storing installed packages...")
	storeData("/.ccpt/installedpackages",{
		ccpt = packagedata["ccpt"]["newestversion"],
		pprint = packagedata["pprint"]["newestversion"]
	})
	print("[Installer] 'ccpt' successfully installed!")
elseif args[1]=="update" then
	print("[Installer] Updating 'ccpt'...")
	if not downloadfile("ccpt","https://raw.githubusercontent.com/PentagonLP/ccpt/main/ccpt") then
		return false
	end
elseif args[1]=="remove" then
	print("[Installer] Uninstalling 'ccpt'...")
	fs.delete("/ccpt")
	fs.delete("/.ccpt")
	shell.setCompletionFunction("ccpt", nil)
	if fs.exists("startup") and startsWith(startup,"-- ccpt: Seach for updates\nshell.run(\"ccpt\",\"startup\")") then
		print("[Installer] Removing 'ccpt' from startup...")
		local startup = readFile("startup","")
		storeFile("startup",string.sub(startup,56))
	end
	print("[Installer] So long, and thanks for all the fish!")
else
	print("[Installer] Invalid argument: " .. args[1])
end
