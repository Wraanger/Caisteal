local F, C = unpack(select(2, ...))

local _, CLASS 		= UnitClass('player')
local COLOR			= CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[CLASS] or RAID_CLASS_COLORS[CLASS]

local f = CreateFrame('Frame', nil, UIParent)
f:SetPoint('TOPLEFT', Minimap, 'BOTTOMLEFT', 0, -9)
f:SetPoint('TOPRIGHT', Minimap, 'BOTTOMRIGHT', 0, -9)
f:SetHeight(10)


local xp = CreateFrame('StatusBar', nil, f)
xp:SetStatusBarTexture(C.Texture)
xp:SetAllPoints(f)
xp:SetFrameLevel(4)
xp:SetStatusBarColor(.4, .1, .6)
F.BD(xp)

local rest = CreateFrame('StatusBar', nil, xp)
rest:SetStatusBarTexture(C.Texture)
rest:SetFrameLevel(3)
rest:EnableMouse(false)
rest:SetStatusBarColor(.2, .4, .8)
rest:SetAllPoints(xp)

local artifact = CreateFrame('StatusBar', nil, f)
artifact:SetPoint('TOPLEFT', Minimap, 'BOTTOMLEFT', 0, UnitLevel'player' == MAX_PLAYER_LEVEL and -9 or -28)
artifact:SetPoint('TOPRIGHT', Minimap, 'BOTTOMRIGHT', 0, UnitLevel'player' == MAX_PLAYER_LEVEL and -9 or -28)
artifact:SetHeight(10)
artifact:SetStatusBarTexture(C.Texture)
artifact:SetFrameLevel(4)
artifact:SetStatusBarColor(230/255, 204/255, 128/255)
F.BD(artifact)

-- DATA METHODS
local factionStanding = {
	[1] = { name = 'Hated' },
	[2] = { name = 'Hostile' },
	[3] = { name = 'Unfriendly' },
	[4] = { name = 'Neutral' },
	[5] = { name = 'Friendly' },
	[6] = { name = 'Honored' },
	[7] = { name = 'Revered' },
	[8] = { name = 'Exalted' },
};

local numberize = function(v)
    if v <= 9999 then return v end
    if v >= 1000000 then
        local value = string.format('%.1fm', v/1000000)
        return value
    elseif v >= 10000 then
        local value = string.format('%.1fk', v/1000)
        return value
    end
end


local xp_update = function()
	local c, m 	= UnitXP('player'), UnitXPMax('player')
	local p 	= math.ceil(c/m*100)
	local r     = GetXPExhaustion()

	if UnitLevel'player' >= MAX_PLAYER_LEVEL or IsXPUserDisabled() then
		xp:Hide() 
		rest:Hide()
	else
		xp:SetMinMaxValues(min(0, c), m)
		xp:SetValue(c)
		rest:SetMinMaxValues(min(0, c), m)
		rest:SetValue(r and (c + r) or 0)
	end
end

local showExperienceTooltip = function(self)
	local xpc, xpm, xpr = UnitXP('player'), UnitXPMax('player'), GetXPExhaustion('player')
	
	GameTooltip:SetOwner(self, 'ANCHOR_NONE')
	GameTooltip:SetPoint('TOPRIGHT', UIParent, -275, -235)
	
	if UnitLevel('player') ~= MAX_PLAYER_LEVEL or IsXPUserDisabled == false then
		GameTooltip:AddLine('Level '..UnitLevel('player'), COLOR.r, COLOR.g, COLOR.b)
		GameTooltip:AddLine((numberize(xpc)..'/'..numberize(xpm)..' ('..floor((xpc/xpm)*100) ..'%)'), 1, 1, 1)
		if xpr then
			GameTooltip:AddLine(numberize(xpr)..' ('..floor((xpr/xpm)*100) ..'%)', .2, .4, .8)
		end
		
		GameTooltip:Show()
	end
end

local artifact_update = function(self, event)
	if HasArtifactEquipped() then
		local id, altid, name, icon, total, spent, q = C_ArtifactUI.GetEquippedArtifactInfo()	
		local num, xp, next = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(spent, total)
		local percent       = math.ceil(xp/next*100)
		
		if not artifact:IsShown() then
			artifact:Show()
		end
	
		artifact:SetMinMaxValues(0, next)
		artifact:SetValue(xp)
	else
		if artifact:IsShown() then
			artifact:Hide()
		end
	end
	if event == 'ARTIFACT_XP_UPDATE' then
		if not artifact:IsShown() then
			artifact:Show()
		end
	end
end

local showArtifactTooltip = function(self) 
	local id, altid, name, icon, total, spent, q = C_ArtifactUI.GetEquippedArtifactInfo()
	local num, xp, next = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(spent, total)
	local percent       = math.ceil(xp/next*100)
	
	GameTooltip:SetOwner(self, 'ANCHOR_NONE')
	GameTooltip:SetPoint('TOPRIGHT', UIParent, -275, -235)
	
	GameTooltip:AddLine(name, COLOR.r, COLOR.g, COLOR.b)
	GameTooltip:AddLine('Artifact Power: '..percent, 1, 1, 1)
	GameTooltip:AddLine('Points to spend: ' .. num, 1, 1, 1)
	GameTooltip:AddLine('Next trait: ' .. xp .. '/' .. next, 1, 1, 1)
	
	GameTooltip:Show()
end

-- events
xp:RegisterEvent('PLAYER_LEVEL_UP')
xp:RegisterEvent('PLAYER_XP_UPDATE')
xp:RegisterEvent('UPDATE_EXHAUSTION')
xp:RegisterEvent('PLAYER_ENTERING_WORLD')
xp:SetScript('OnEvent', xp_update)
xp:SetScript('OnEnter', function() showExperienceTooltip(xp) end)
xp:SetScript('OnLeave', function() GameTooltip:Hide() end)

artifact:RegisterEvent('PLAYER_ENTERING_WORLD')
artifact:RegisterEvent('ARTIFACT_XP_UPDATE')
artifact:RegisterEvent('ARTIFACT_UPDATE')
artifact:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
artifact:RegisterEvent('PLAYER_LEVEL_UP')
artifact:SetScript('OnEvent', artifact_update)
artifact:SetScript('OnEvent', artifact_update)
artifact:SetScript('OnEnter', function() showArtifactTooltip(artifact) end)
artifact:SetScript('OnLeave', function() GameTooltip:Hide() end)