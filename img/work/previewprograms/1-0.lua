--[[
	ComputerCaft Package Tool 1.0 Display Version (Used to create social preview)
	Version: 1.0
	Author: PentagonLP
	Note: Some function names are in German, but as it would take some time to translate them and nobody really cares about this program anyways, it doesn't really matter.
]]--
function gibZentriert(size,text)
	return round((size-#text)/2,0)
end

function schreibeZentriert(mon,text,line) 
	xsize,ysize = mon.getSize()
	mon.setCursorPos(gibZentriert(xsize,text),line)
	mon.write(text)
end

function gibRechtsbuendig(size,text)
	return size-#text
end

function schreibeRechtsbuendig(mon,text,line) 
	xsize,ysize = mon.getSize()
	mon.setCursorPos(gibRechtsbuendig(xsize,text),line)
	mon.write(text)
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- Change "top" to the address of your own monitor
mon = peripheral.wrap("top")
mon.clear()
mon.setTextColor(colors.white)
schreibeZentriert(mon, "< ComputerCraft Package Tool >", 2)
schreibeZentriert(mon, "Version 1.0", 4)
mon.setTextColor(colors.yellow)
schreibeZentriert(mon, "First Alpha Release!", 6)
mon.setTextColor(colors.white)
mon.setCursorBlink(true)
