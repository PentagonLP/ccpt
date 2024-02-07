local web = {}

--requires
local properprint = require("lib.properprint")
local files = require("lib.ccpt.files")
local data = require("lib.ccpt.data")


-- HTTP FETCH FUNCTIONS --
--[[ Gets result of HTTP URL
	@param String url: The desired URL
	@return Table|boolean result|error: The result of the request; If the URL is not reachable, an error is printed in the terminal and boolean false is returned
--]]
local function gethttpresult(url)
	if not http.checkURL(data.defaultpackageurl) then
		properprint.pprint("ERROR: Url '" .. url .. "' is blocked in config. Unable to fetch data.")
		return false
	end
	local result = http.get(url)
	if result == nil then
		properprint.pprint("ERROR: Unable to reach '" .. url .. "'")
		return false
	end
	return result
end
web.gethttpresult = gethttpresult

--[[ Gets table from HTTP URL
	@param String url: The desired URL
	@return Table|boolean result|error: The content of the site parsed into a table; If the URL is not reachable, an error is printed in the terminal and boolean false is returned
--]]
local function gethttpdata(url)
	local result = gethttpresult(url)
	if result == false then 
		return false
	end
	data = result.readAll()
	data = string.gsub(data,"\n","")
	return textutils.unserializeJSON(data)
end
web.gethttpdata = gethttpdata

--[[ Download file HTTP URL
	@param String filepath: Filepath where to create file (if file already exists, it gets overwritten)
	@param String url: The desired URL
	@return nil|boolean nil|error: nil; If the URL is not reachable, an error is printed in the terminal and boolean false is returned
--]]
local function downloadfile(filepath,url)
	result = gethttpresult(url)
	if result == false then 
		return false
	end
	files.storeFile(filepath,result.readAll())
end
web.downloadfile = downloadfile
return web