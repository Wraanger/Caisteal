local addon, core = ...

core[1] = {} -- Functions
core[2] = {} -- Constants

local F, C = unpack(select(2, ...))

-- [[ Event handler ]]

local eventFrame = CreateFrame('Frame')
local events = {}

eventFrame:SetScript('OnEvent', function(_, event, ...)
	for i = #events[event], 1, -1 do
		events[event][i](event, ...)
	end
end)

F.RegisterEvent = function(event, func)
	if not events[event] then
		events[event] = {}
		eventFrame:RegisterEvent(event)
	end
	table.insert(events[event], func)
end

F.UnregisterEvent = function(event, func)
	for index, tFunc in ipairs(events[event]) do
		if tFunc == func then
			table.remove(events[event], index)
		end
	end
	if #events[event] == 0 then
		events[event] = nil
		eventFrame:UnregisterEvent(event)
	end
end

F.UnregisterAllEvents = function(func)
	for event in next, events do
		F.UnregisterEvent(event, func)
	end
end

F.debugEvents = function()
	for event in next, events do
		print(event..': '..#events[event])
	end
end

-- [[ For secure frame hiding ]]
local hider = CreateFrame('Frame', 'CaistealHider', UIParent)
hider:Hide()

-- [[ Resolution support ]]
local updateScale = function(event)
	if not InCombatLockdown() then
		-- we don't bother with the cvar because of high resolution shenanigans
		UIParent:SetScale(768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], '%d+x(%d+)'))
	else
		F.RegisterEvent('PLAYER_REGEN_ENABLED', updateScale)
	end

	if event == 'PLAYER_REGEN_ENABLED' then
		F.UnregisterEvent('PLAYER_REGEN_ENABLED', updateScale)
	end
end
F.RegisterEvent('VARIABLES_LOADED', updateScale)
F.RegisterEvent('UI_SCALE_CHANGED', updateScale)