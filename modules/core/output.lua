-------------------------------------------------------------------------------------------------------------------------------------------------------------------
--This is a beatiful piece of code from p3lim's Inomena. 
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local E, F = unpack(select(2, ...))

local debugging = false
function F:Debug(...)
	if(debugging) then
		print('|cff00ff00Caisteal|r:', ...)
	end
end

function F:Error(...)
	print('|cffff9999Caisteal|r:', ...)
end

function F:Print(...)
	print('|cff0090ffCaisteal|r:', ...)
end