local F, C = unpack(select(2, ...))

local minimapAnchor = CreateFrame('Frame', nil, UIParent)
minimapAnchor:SetSize(150, 150)
minimapAnchor:SetPoint('TOPRIGHT', -30, -30)

F.BD(minimapAnchor)

Minimap:SetParent(minimapAnchor)
Minimap:SetSize(150, 150)
Minimap:SetMaskTexture(C.PlainTexture)
Minimap:ClearAllPoints()
Minimap:SetAllPoints(minimapAnchor)

function GetMinimapShape() return 'SQUARE' end
function TimeManager_LoadUI() end

-- click functionality
Minimap:SetScript('OnMouseUp', function(self, button)
	Minimap:StopMovingOrSizing()
	if button == 'RightButton' then
		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self, - (Minimap:GetWidth() * .7), -3)
	elseif button == 'MiddleButton' then
		ToggleCalendar()
	else
		Minimap_OnClick(self)
	end
end)

-- scrolling zoom
Minimap:EnableMouseWheel(true)
MinimapCluster:EnableMouse(false)
Minimap:SetScript('OnMouseWheel', function(self, arg1)
	if arg1 > 0 then Minimap_ZoomIn() else Minimap_ZoomOut() end
end)

Minimap:SetArchBlobRingScalar(0)
Minimap:SetArchBlobRingAlpha(0)
Minimap:SetQuestBlobRingScalar(0)
Minimap:SetQuestBlobRingAlpha(0)

for _, name in next, {
	'GameTimeFrame',
	'MinimapBorder',
	'MinimapBorderTop',
	'MinimapNorthTag',
	'MinimapZoomIn',
	'MinimapZoomOut',
	'MinimapZoneTextButton',
	'MiniMapMailBorder',
	'MiniMapTracking',
	'MiniMapWorldMapButton',
	'QueueStatusMinimapButtonBorder',
	'QueueStatusMinimapButtonGroupSize',
	'MiniMapVoiceChatFrame',
	'MiniMapInstanceDifficulty',
} do
	local object = _G[name]
	if(object:GetObjectType() == 'Texture') then
		object:SetTexture(nil)
	else
		object.Show = object.Hide
		object:Hide()
	end
end
MiniMapInstanceDifficulty:UnregisterAllEvents()
GuildInstanceDifficulty:SetAlpha(0)
MiniMapChallengeMode:GetRegions():SetTexture("")

local garrison = GarrisonLandingPageMinimapButton
garrison:ClearAllPoints()
garrison:SetParent(Minimap)
garrison:SetPoint('TOPRIGHT')
garrison:SetSize(32, 32)
garrison.t = F.CreateFS(garrison, C.FONTBIG, 15)
garrison.t:SetPoint('TOPRIGHT', -3, -3)

garrison:SetScript('OnEnter', function(self) 
	garrison.t:SetTextColor(1, .8, 0)
end)

garrison:SetScript('OnLeave', function(self) 
	garrison.t:SetTextColor(1, 1, 1)
end)
GarrisonMinimapBuilding_ShowPulse = function() end
-- garrison
hooksecurefunc('GarrisonLandingPageMinimapButton_UpdateIcon', function(self)
	self:SetNormalTexture''
	self:SetPushedTexture''
	self:SetHighlightTexture''
	if C_Garrison.GetLandingPageGarrisonType() == LE_GARRISON_TYPE_6_0 then
		self.title = GARRISON_LANDING_PAGE_TITLE
		self.description = MINIMAP_GARRISON_LANDING_PAGE_TOOLTIP
		garrison.t:SetText('G')
	else
		self.title = ORDER_HALL_LANDING_PAGE_TITLE
		self.description = MINIMAP_ORDER_HALL_LANDING_PAGE_TOOLTIP
		garrison.t:SetText('OH')
	end
end)

local lfg  = QueueStatusMinimapButton
lfg:ClearAllPoints()
lfg:SetParent(Minimap)
lfg:SetPoint('BOTTOMLEFT')
lfg:SetSize(25, 15)
lfg:SetHighlightTexture(nil)
lfg.Eye:Hide()
lfg.Eye:SetScript('OnShow', function(self) self:Hide() end)
lfg.t = F.CreateFS(lfg, C.FONTBIG, 12)
lfg.t:SetPoint('BOTTOMLEFT', 3, 3)
lfg.t:SetText('LFG')

local mail = MiniMapMailFrame
mail:ClearAllPoints()
mail:SetParent(Minimap)
mail:SetPoint('BOTTOMRIGHT')
mail:SetSize(15, 15)
MiniMapMailIcon:SetTexture''
mail.t = F.CreateFS(mail, C.FONTBIG, 15)
mail.t:SetPoint('BOTTOMRIGHT', -3, 3)
mail.t:SetText('|cff00d5d7M|r')


--Raid difficulty
local rd = CreateFrame("Frame", nil, Minimap)
rd:SetSize(24, 8)
rd:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 3, -3)
rd:RegisterEvent("PLAYER_ENTERING_WORLD")
rd:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")
rd:RegisterEvent("GUILD_PARTY_STATE_UPDATED")
rd:RegisterEvent("INSTANCE_GROUP_SIZE_CHANGED")

local rdt = F.CreateFS(rd, C.FONTBIG, 15, "LEFT")
rdt:SetPoint("TOPLEFT")

local instanceTexts = {
	[0] = "",
	[1] = "5",
	[2] = "5H",
	[3] = "10",
	[4] = "25",
	[5] = "10H",
	[6] = "25H",
	[7] = "RF",
	[8] = "CM",
	[9] = "40",
	[11] = "3H",
	[12] = "3",
	[16] = "M",
	[23] = "5M",	-- Mythic 5-player
	[24] = "5T",	-- Timewalker 5-player
}

rd:SetScript("OnEvent", function()
	local inInstance, instanceType = IsInInstance()
	local _, _, difficultyID, _, maxPlayers, _, _, _, instanceGroupSize = GetInstanceInfo()

	if instanceTexts[difficultyID] ~= nil then
		rdt:SetText(instanceTexts[difficultyID])
	else
		if difficultyID == 14 then
			rdt:SetText(instanceGroupSize.."N")
		elseif difficultyID == 15 then
			rdt:SetText(instanceGroupSize.."H")
		elseif difficultyID == 17 then
			rdt:SetText(instanceGroupSize.."RF")
		else
			rdt:SetText("")
		end
	end

	rd:SetShown(inInstance and (instanceType == "party" or instanceType == "raid" or instanceType == "scenario"))

	if GuildInstanceDifficulty:IsShown() then
		rdt:SetTextColor(0, .9, 0)
	else
		rdt:SetTextColor(1, 1, 1)
	end
end)

	-- WORLD STATE CAP BAR
hooksecurefunc('UIParent_ManageFramePositions', function()
	if NUM_EXTENDED_UI_FRAMES then
		for i = 1, NUM_EXTENDED_UI_FRAMES do
			local bar = _G['WorldStateCaptureBar'..i]
			if bar and bar:IsVisible() then
				bar:ClearAllPoints()
				if i == 1 then
					bar:SetPoint('TOP', MinimapCluster, 'BOTTOM', 5, -30)
				else
					bar:SetPoint('TOP', _G['WorldStateCaptureBar'..(i - 1)], 'BOTTOM', 0, -20)
				end
			end
		end
	end
end)