local F, C = unpack(select(2, ...))

local f = CreateFrame('Frame', nil, UIParent)
f:SetSize(0, 30)
f:SetPoint('RIGHT')
f:SetPoint('LEFT')
f:SetPoint('BOTTOM')
f:SetFrameStrata('HIGH')
f:SetFrameLevel(20)
F.BD(f)

-- zone text
local function GetZoneColor()
	local zoneType = GetZonePVPInfo()
	if (zoneType == 'sanctuary') then
		return 0.4, 0.8, 0.94
	elseif (zoneType == 'arena') then
		return 1, 0.1, 0.1
	elseif (zoneType == 'friendly') then
		return 0.1, 1, 0.1
	elseif (zoneType == 'hostile') then
		return 1, 0.1, 0.1
	elseif (zoneType == 'contested') then
		return 1, 0.8, 0
	else
		return 1, 1, 1
	end
end
local totalElapsed = 0
local function UpdateCoords(self, elapsed)
	if(totalElapsed > 0.1) then
		local x, y = GetPlayerMapPosition('player')
		CoordText:SetFormattedText('%.2f, %.2f', x * 100, y * 100)
		CoordText:SetTextColor(1, 1, 0)

		totalElapsed = 0
	else
		totalElapsed = totalElapsed + elapsed
	end
end

local zone = Minimap:CreateFontString(nil, 'OVERLAY')
zone:SetFont(C.FONT, 16, 'OUTLINE')
zone:SetPoint('BOTTOM', f, 0, 8)
zone:SetShadowOffset(1, -1)
zone:SetShadowColor(0, 0, 0)
zone:SetAlpha(1)
zone:SetSize(500, 14)
zone:SetJustifyH('CENTER')
zone:SetTextColor(GetZoneColor())


if GetSubZoneText() == '' then
	zone:SetText(GetZoneText())
else 
	zone:SetText(GetSubZoneText())
end

Minimap:HookScript('OnUpdate', function()
	if GetSubZoneText() == '' then
		zone:SetText(GetZoneText())
	else 
		zone:SetText(GetSubZoneText())
	end
	zone:SetTextColor(GetZoneColor())
end)



local CoordText = f:CreateFontString(nil, 'OVERLAY')
CoordText:SetFont(C.FONT, 14, 'OUTLINE')
CoordText :SetWidth(100)
CoordText :SetPoint('LEFT', zone, 'RIGHT', 10, 0)