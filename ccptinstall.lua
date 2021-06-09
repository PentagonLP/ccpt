--[[ 
	ComputerCraft Package Tool Installer
	Author: PentagonLP
	Version: 1.1
]]

-- Read arguments
args = {...}

-- FILE MANIPULATION FUNCTIONS --
--[[ Checks if file exists
	@param String filepath: Filepath to check
	@return boolean: Does the file exist?
--]]
function file_exists(filepath)
	local f=io.open(filepath,"r")
	if f~=nil then 
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
function storeFile(filepath,content)
	writefile = fs.open(filepath,"w")
	writefile.write(content)
	writefile.close()
end

--[[ Reads a file from a desired location
	@param String filepath: Filepath to the file to read
	@param String createnew: (Optional) Content to store in new file and return if file does not exist. Can be nil.
	@return String|boolean content|error: Content of the file; If createnew is nil and file doesn't exist boolean false is returned
--]]
function readFile(filepath,createnew)
	readfile = fs.open(filepath,"r")
	if readfile == nil then
		if not (createnew==nil) then
			storeFile(filepath,createnew)
			return createnew
		else
			return false
		end
	end
	content = readfile.readAll()
	readfile.close()
	return content
end

--[[ Stores a table in a file
	@param String filepath: Filepath where to create file (if file already exists, it gets overwritten)
	@param Table data: Table to store in file
--]]
function storeData(filepath,data)
	storeFile(filepath,textutils.serialize(data):gsub("\n",""))
end

--[[ Reads a table from a file in a desired location
	@param String filepath: Filepath to the file to read
	@param boolean createnew: If true, an empty table is stored in new file and returned if file does not exist.
	@return Table|boolean content|error: Table thats stored in the file; If createnew is false and file doesn't exist boolean false is returned
--]]
function readData(filepath,createnew)
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
function gethttpresult(url)
	if not http.checkURL(url) then
		print("ERROR: Url '" .. url .. "' is blocked in config. Unable to fetch data.")
		return false
	end
	result = http.get(url)
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
function downloadfile(filepath,url)
	result = gethttpresult(url)
	if result == false then 
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
function startsWith(haystack,needle)
	return string.sub(haystack,1,string.len(needle))==needle
end

function regexEscape(str)
	return str:gsub("[%(%)%.%%%+%-%*%?%[%^%$%]]", "%%%1")
end

toInstall = {
	pprint = {
		url = "https://raw.githubusercontent.com/PentagonLP/properprint/main/properprint",
		path = "lib/properprint"
	},
	fileutils = {
		url = "https://raw.githubusercontent.com/PentagonLP/fileutils/main/fileutils",
		path = "lib/fileutils"
	},
	httputils = {
		url = "https://raw.githubusercontent.com/PentagonLP/httputils/main/httputils",
		path = "lib/httputils"
	},
	ccpt = {
		url = "https://raw.githubusercontent.com/PentagonLP/ccpt/main/ccpt.lua",
		path = ".ccpt/program/ccpt"
	}
}

-- MAIN PROGRAMM --
if (args[1]=="install") or (args[1]==nil) then
	print("[Installer] Well, hello there!")
	print("[Installer] Thank you for downloading the ComputerCraft Package Tool! Installing...")
	for k,v in pairs(toInstall) do
		print("[Installer] Installing '" .. k .. "'...")
		if downloadfile(v["path"],v["url"])== false then
			return false
		end
		print("[Installer] Successfully installed '" .. k .. "'!")
	end
	print("[Installer] Running 'ccpt update'...")
	shell.run(".ccpt/program/ccpt","update")
	print("[Installer] Reading package data...")
	packagedata = readData("/.ccpt/packagedata")
	print("[Installer] Storing installed packages...")
	installedpackages = {}
	for k,v in pairs(toInstall) do
		installedpackages[k] = packagedata[k]["newestversion"]
	end
	storeData("/.ccpt/installedpackages",installedpackages)
	print("[Installer] Install of 'ccpt' finished!")
elseif args[1]=="update" then
	print("[Installer] Updating 'ccpt'...")
	if downloadfile(".ccpt/program/ccpt","https://raw.githubusercontent.com/PentagonLP/ccpt/main/ccpt")==false then
		return false
	end
elseif args[1]=="remove" then
	print("[Installer] Uninstalling 'ccpt'...")
	fs.delete("/.ccpt")
	shell.setCompletionFunction("ccpt", nil)
	shell.setPath(string.gsub(shell.path(),regexEscape(":.ccpt/program","")))
	if file_exists("startup") then
		print("[Installer] Removing 'ccpt' from startup...")
		startup = readFile("startup","")
		startup = string.gsub(startup,regexEscape("-- ccpt: Search for updates"), "")
		startup = string.gsub(startup,regexEscape("shell.run(\".ccpt/program/ccpt\",\"startup\")"), "")
		storeFile("startup",startup)
	end
	print("[Installer] So long, and thanks for all the fish!")
else
	print("[Installer] Invalid argument: " .. args[1])
end