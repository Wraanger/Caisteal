local addon, core = ...
local oUF = core.oUF
local F, C = unpack(select(2, ...))

local _, CLASS = UnitClass'player'
local TEXTURE = C.Texture
local ABSORBTEXTURE = C.Texture
local FONT = C.FONT
local FONTBIG = C.FONTBIG
local CLASSCOLOR = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[CLASS] or RAID_CLASS_COLORS[CLASS]

local floor, fmod = floor, math.fmod
local day, hour, minute = 86400, 3600, 60
local formatTime = function(s)
    if s >= day then
        return format('%dd', floor(s/day + 0.5))
    elseif s >= hour then
        return format('%dh', floor(s/hour + 0.5))
    elseif s >= minute then
        return format('%dm', floor(s/minute + 0.5))
    end
    return format('%d', fmod(s, minute))
end

local PostUpdateHealth = function(Health, unit, min, max)
	if  UnitIsDead(unit) or UnitIsGhost(unit) then
		Health:SetValue(0)
	end
end

local RAID_TARGET_UPDATE = function(self, event)
	local index = GetRaidTargetIndex(self.unit)
	if(index) then
		self.RIcon:SetText(ICON_LIST[index].."23|t")
	else
		self.RIcon:SetText()
	end
end

local PostUpdateClassIcon = function(element, cur, max, diff, event)
	if(diff or event == 'ClassPowerEnable') then
		element:UpdateTexture()
	end
end

local UpdateClassIconTexture = function(element)
	local r, g, b
	if(CLASS == 'MONK') then
		r, g, b = 0, 4/5, 3/5
	elseif(CLASS == 'WARLOCK') then
		r, g, b = 2/3, 1/3, 2/3
	elseif(CLASS == 'PRIEST') then
		r, g, b = 2/3, 1/4, 2/3
	elseif(CLASS == 'PALADIN') then
		r, g, b = 1, 1, 2/5
	elseif(CLASS == 'MAGE') then
		r, g, b = 5/6, 1/2, 5/6
	else
		r, g, b = 1, 228/255, 0
	end

	for index = 1, 8 do
		local ClassIcon = element[index]
		ClassIcon.Texture:SetColorTexture(r, g, b)
	end
end

local CastbarCheckShield = function(self, unit)
    if self.interrupt and UnitCanAttack("player", unit) then
      --show shield
      self:SetStatusBarColor(.4, .4, .4, 1)
    else
      --no shield
	  if unit == 'player' then
		self:SetStatusBarColor(CLASSCOLOR.r, CLASSCOLOR.g, CLASSCOLOR.b, 1)
	  else
		--self:SetStatusBarColor(218/255,51/255,102/255,1)
		self:SetStatusBarColor(12/255,211/255,99/255,1)
	  end
    end
  end
  
local CastbarCheckCast = function(bar, unit, name, rank, castid)
    CastbarCheckShield(bar, unit)
  end
  
local CastbarCheckChannel = function(bar, unit, name, rank)
    CastbarCheckShield(bar, unit)
end
  
local CastbarCustomTimeText = function(self, duration)
	self.Time:SetFormattedText("%.1f", self.max - duration)
end

local CreateCastbar = function(self, unit) 


	local castbar = CreateFrame("StatusBar", "oUF_LynCastbarTarget", self)
	
	castbar:SetStatusBarTexture(TEXTURE)
		
	if unit == 'target' then
		castbar:SetHeight(24)
		castbar:SetWidth(300)
		castbar:SetPoint("BOTTOM", self, "TOP", 0, 175)
		--castbar:SetPoint("CENTER", UIParent, 0, -150)
		
		--castbar:SetStatusBarColor(255/255,174/255,0/255,1)
		
		local castbarBg = castbar:CreateTexture(nil, "BACKGROUND")
		castbarBg:SetTexture(TEXTURE)
		castbarBg:SetPoint('TOPLEFT', castbar, -1, 1)
		castbarBg:SetPoint('BOTTOMRIGHT', castbar, 1, -1)
		castbarBg:SetVertexColor(0, 0, 0, 1)
		
			
		local castbarSpark = castbar:CreateTexture(nil,'OVERLAY')
		castbarSpark:SetBlendMode('Add')
		castbarSpark:SetHeight(castbar:GetHeight() * 2.3)
		castbarSpark:SetWidth(10)
		castbarSpark:SetVertexColor(1, 1, 1)
		castbar.Spark = castbarSpark
	
		local castbarText = castbar:CreateFontString(nil, "OVERLAY")
		castbarText:SetFont(FONTBIG, 12)
		castbarText:SetShadowColor(0,0,0,0.8)
		castbarText:SetShadowOffset(1,-1)
		castbarText:SetPoint('LEFT', castbar, 'LEFT', 5, 0)
		castbarText:SetJustifyH('LEFT')
		castbar.Text = castbarText
		
		local castbarTime = castbar:CreateFontString(nil, "OVERLAY")
		castbarTime:SetFont(FONTBIG, 12)
		castbarTime:SetShadowColor(0,0,0,0.8)
		castbarTime:SetShadowOffset(1,-1)
		castbarTime:SetPoint('RIGHT', castbar, 'RIGHT', -5, 0)
		castbarTime:SetJustifyH('RIGHT')
		castbar.Time = castbarTime
				
		local trans = CreateFrame('Frame', nil, castbar)
		trans:SetBackdrop({
			bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
			tiled = false,
			insets = {left = -3, right = -3, top = -3, bottom = -3}
		})
		trans:SetAllPoints(castbar)
		trans:SetFrameLevel(0)
		trans:SetFrameStrata('BACKGROUND')
		trans:SetBackdropColor(0, 0, 0, 0.6)
	elseif unit == 'player' then
		castbar:SetHeight(self:GetHeight())
		castbar:SetWidth(self:GetWidth())
		castbar:SetPoint("TOPLEFT", self, -1, 1)
		castbar:SetPoint("BOTTOMRIGHT", self, 1, 6)
		castbar:SetFrameStrata('BACKGROUND')	
		castbar:SetAlpha(0.6)

    end
		
	self.Castbar = castbar
	
	self.Castbar.CustomTimeText = CastbarCustomTimeText
	self.Castbar.PostCastStart = CastbarCheckCast
	self.Castbar.PostChannelStart = CastbarCheckChannel

end

local Shared = function(self, unit, isSingle)
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self:RegisterForClicks"AnyUp"
	self:SetSize(150, 20)
	if unit == 'targettarget' or unit == 'pet' then
		local name = self:CreateFontString(nil, "OVERLAY")
		name:SetPoint("RIGHT", self, 0, 0)
		name:SetJustifyH"RIGHT"
		name:SetFont(FONT, 12, 'OUTLINE')
		name:SetShadowOffset(1, -1.25)
		name:SetShadowColor(0, 0, 0, 1)
		name:SetTextColor(1, 1, 1)

		self.Name = name
		self:Tag(self.Name, '[lyn:color][lyn:name]')
	else
		local Health = CreateFrame("StatusBar", nil, self)
		Health:SetStatusBarTexture(TEXTURE)
		Health:SetStatusBarColor(.25, .25, .25)

		Health.colorTapping = true
		Health.Smooth = true
		Health.frequentUpdates = true

		Health:SetPoint"TOP"
		Health:SetPoint"LEFT"
		Health:SetPoint"RIGHT"

		self.Health = Health

		local Background = Health:CreateTexture(nil, 'BORDER')
		Background:SetTexture(1, 0, 0, 1)
		Background:SetAllPoints()

		local HealthPoints = Health:CreateFontString(nil, "OVERLAY")
		HealthPoints:SetPoint("RIGHT", -2, 0)
		HealthPoints:SetFontObject(GameFontNormalSmall)
		HealthPoints:SetTextColor(1, 1, 1)
		self:Tag(HealthPoints, '[lyn:health]')

		Health.value = HealthPoints


		Health.PostUpdate = PostUpdateHealth
	end
end

local UnitSpecific = {
	player = function(self, ...)
		Shared(self, ...)
		self:SetWidth(350)
		self:SetHeight(42)
		
		local hpText = self.Health.value
		hpText:SetFont(FONTBIG, 22, 'OUTLINE')
		hpText:SetShadowOffset(1,-1)
		hpText:ClearAllPoints()
		hpText:SetPoint("RIGHT", -7, 0)
		self:Tag(hpText, '[lyn:hpp]')		
		self.Health.value = hpText
		
		local hpv = self.Health:CreateFontString(nil, "OVERLAY")
		hpv:SetPoint('RIGHT', hpText, 'LEFT', -5, 0)
		hpv:SetJustifyH'RIGHT'
		hpv:SetFont(FONTBIG, 10, 'OUTLINE')
		hpv:SetShadowOffset(1, -1)
		hpv:SetShadowColor(0, 0, 0, 1)
		hpv:SetTextColor(.8, .8, .8)
		self:Tag(hpv, '[lyn:hpv]')
		
		local power = self.Health:CreateFontString(nil, "OVERLAY")
		power:SetPoint("CENTER", self, 0, 3)
		power:SetShadowColor(0, 0, 0, 1)
		power:SetTextColor(1, 1, 1)
		power:SetShadowOffset(1,-1.25)
		power:SetJustifyH'LEFT'
		power:SetFont(FONTBIG, 32, 'OUTLINE')
		power:SetTextColor(1, 1, 1)
		self:Tag(power, '[lyn:power]')
		
	end,
	target = function(self, ...)
		Shared(self, ...)
		self:SetWidth(350)
		self:SetHeight(42)
		
		local hpText = self.Health.value
		hpText:SetFont(FONTBIG, 22, 'OUTLINE')
		hpText:SetShadowOffset(1,-1)
		hpText:ClearAllPoints()
		hpText:SetPoint("RIGHT", -7, 0)
		self:Tag(hpText, '[lyn:hpp]')		
		self.Health.value = hpText
		
		local hpv = self.Health:CreateFontString(nil, "OVERLAY")
		hpv:SetPoint('RIGHT', hpText, 'LEFT', -5, 0)
		hpv:SetJustifyH'RIGHT'
		hpv:SetFont(FONTBIG, 10, 'OUTLINE')
		hpv:SetShadowOffset(1, -1)
		hpv:SetShadowColor(0, 0, 0, 1)
		hpv:SetTextColor(.8, .8, .8)
		self:Tag(hpv, '[lyn:hpv]')
		
		local name = self.Health:CreateFontString(nil, "OVERLAY")
		name:SetJustifyH"LEFT"
		name:SetShadowColor(0, 0, 0, 1)
		name:SetTextColor(1, 1, 1)
		name:SetShadowOffset(1,-1)
		name:SetFont(FONT, 16, 'OUTLINE')
		name:SetPoint("LEFT", self.Health, 7, 0)
		name:SetWidth(360)
		
		self.Name = name
		self:Tag(self.Name, '[lyn:targetname]')	
	end,
	targettarget = function(self, ...)
		Shared(self, ...)
	end,
	focus = function(self, ...)
		Shared(self, ...)
	end,
	pet = function(self, ...)
		Shared(self, ...)
	end,
}

do
	local range = {
		insideAlpha = 1,
		outsideAlpha = .5,
	}

	UnitSpecific.party = function(self, ...)
		Shared(self, ...)
	end
	UnitSpecific.raid = function(self, ...)
		Shared(self, ...)
	end
	UnitSpecific.boss = function(self, ...)
		Shared(self, ...)
	end
end

oUF:RegisterStyle("Caisteal", Shared)
for unit,layout in next, UnitSpecific do
	-- Capitalize the unit name, so it looks better.
	oUF:RegisterStyle('Caisteal - ' .. unit:gsub("^%l", string.upper), layout)
end

-- A small helper to change the style into a unit specific, if it exists.
local spawnHelper = function(self, unit, ...)
	if(UnitSpecific[unit]) then
		self:SetActiveStyle('Caisteal - ' .. unit:gsub("^%l", string.upper))
	elseif(UnitSpecific[unit:match('%D+')]) then -- boss1 -> boss
		self:SetActiveStyle('Caisteal - ' .. unit:match('%D+'):gsub("^%l", string.upper))
	else
		self:SetActiveStyle'Caisteal'
	end

	local object = self:Spawn(unit)
	object:SetPoint(...)
	return object
end

oUF:Factory(function(self)
	spawnHelper(self, 'player', 'BOTTOM', 0, 200)
	spawnHelper(self, 'target', 'BOTTOM', oUF_CaistealPlayer, 'TOP', 0, 10)
	spawnHelper(self, 'targettarget', 'BOTTOMRIGHT', oUF_CaistealTarget, 'TOPRIGHT', 2, 0)
	spawnHelper(self, 'focus', "CENTER", -314, 90)
	spawnHelper(self, 'pet', 'BOTTOM', -37, 178)

	for n=1, MAX_BOSS_FRAMES or 5 do
		--spawnHelper(self, 'boss' .. n, 'TOPRIGHT', -50, -300 - (36 * n))
		spawnHelper(self, 'boss' .. n, 'TOPRIGHT', -50, -270 - (36 * n))
	end

	self:SetActiveStyle'Caisteal - Party'
	local party = self:SpawnHeader(
		nil, nil, 'party',
		'showParty', true, 
		'showPlayer', true, 
		'showRaid', false,
		'showSolo', true, 
		'yOffset', -9,
		'oUF-initialConfigFunction', [[
			self:SetHeight(18)
			self:SetWidth(140)
		]]
	)
	party:SetPoint("TOPLEFT", 80, -60)
	--party:SetPoint("TOPLEFT", 80, -90)
	
	self:SetActiveStyle'Caisteal - Raid'
	local raid = self:SpawnHeader(
		nil, nil, 'raid',
		'showParty', true, 
		'showPlayer', true, 
		'showRaid', true,
		'showSolo', true, 
		'yOffset', -9,
		'columnSpacing', 35,
		'startingIndex', 1,
		'groupBy', 'GROUP',
		'unitsPerColumn', 25,
		'maxColumns', 8,
		'columnAnchorPoint', 'LEFT',
		'groupingOrder', '1,2,3,4,5,6,7,8',
		'oUF-initialConfigFunction', [[
			self:SetHeight(10)
			self:SetWidth(120)
		]]
	)
	raid:SetPoint("TOPLEFT", 80, -60)
	--raid:SetPoint("TOPLEFT", 80, -90)
	
end)


SlashCmdList["TESTBOSS"] = function()
    oUF_CaistealBoss1:Show(); oUF_CaistealBoss1.Hide = function() end oUF_CaistealBoss1.unit = "player"
    oUF_CaistealBoss2:Show(); oUF_CaistealBoss2.Hide = function() end oUF_CaistealBoss2.unit = "player"
    oUF_CaistealBoss3:Show(); oUF_CaistealBoss3.Hide = function() end oUF_CaistealBoss3.unit = "player"
    oUF_CaistealBoss4:Show(); oUF_CaistealBoss4.Hide = function() end oUF_CaistealBoss4.unit = "player"
	oUF_CaistealBoss5:Show(); oUF_CaistealBoss5.Hide = function() end oUF_CaistealBoss5.unit = "player"
end
SLASH_TESTBOSS1 = "/tb"

	