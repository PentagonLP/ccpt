local files = {}

-- FILE MANIPULATION FUNCTIONS --
--[[ Checks if file exists
	@param String filepath: Filepath to check
	@return boolean: Does the file exist?
--]]
local function file_exists(filepath)
	local f=io.open(filepath,"r")
	if f~=nil then 
		io.close(f) 
		return true 
	else 
		return false 
	end
end
files.file_exists = file_exists

--[[ Stores a file in a desired location
	@param String filepath: Filepath where to create file (if file already exists, it gets overwritten)
	@param String content: Content to store in file
--]]
local function storeFile(filepath,content)
	local writefile = fs.open(filepath,"w")
	writefile.write(content)
	writefile.close()
end
files.storeFile = storeFile

--[[ Reads a file from a desired location
	@param String filepath: Filepath to the file to read
	@param String createnew: (Optional) Content to store in new file and return if file does not exist. Can be nil.
	@return String|boolean content|error: Content of the file; If createnew is nil and file doesn't exist boolean false is returned
--]]
local function readFile(filepath,createnew)
	local readfile = fs.open(filepath,"r")
	if readfile == nil then
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
files.readFile = readFile

--[[ Stores a table in a file
	@param String filepath: Filepath where to create file (if file already exists, it gets overwritten)
	@param Table data: Table to store in file
--]]
local function storeData(filepath,data)
	storeFile(filepath,textutils.serializeJSON(data):gsub("\n",""))
end
files.storeData = storeData

--[[ Reads a table from a file in a desired location
	@param String filepath: Filepath to the file to read
	@param boolean createnew: If true, an empty table is stored in new file and returned if file does not exist.
	@return Table|boolean content|error: Table thats stored in the file; If createnew is false and file doesn't exist boolean false is returned
--]]
local function readData(filepath,createnew)
	if createnew then
		return textutils.unserializeJSON(readFile(filepath,textutils.serializeJSON({}):gsub("\n","")))
	else
		return textutils.unserializeJSON(readFile(filepath,nil))
	end
end
files.readData = readData
return files