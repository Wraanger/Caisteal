local F, C = unpack(select(2, ...))

C.Settings = {}
local function Initialize()
	for _, update in next, C.Settings do
		update()
	end

	print('|cffff6000Caisteal:|r Successfully initialized settings')
	CaistealSettings = true
end

local function Decline()
	print('|cffff6000Caisteal:|r Settings not initialized')
	CaistealSettings = true
end

StaticPopupDialogs.CAISTEAL_INITIALIZE = {
	text = '|cffff6000Caisteal:|r Load settings?',
	button1 = YES,
	button2 = NO,
	OnAccept = Initialize,
	OnCancel = Decline,
	timeout = 0
}
local function launch()
	if(not CaistealSettings) then
		StaticPopup_Show('CAISTEAL_INITIALIZE')
	end
	F.UnregisterEvent('PLAYER_LOGIN', launch)
end
F.RegisterEvent('PLAYER_LOGIN', launch)