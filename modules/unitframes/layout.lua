local E, F, C = unpack(select(2, ...))
local _, private = ...
local oUF = private.oUF

local _, CLASS = UnitClass'player'
local TEXTURE = C.Texture
local FONT = C.FONT
local FONTBIG = C.FONTBIG
local CLASSCOLOR = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[CLASS] or RAID_CLASS_COLORS[CLASS]

local PostUpdateHealth = function(Health, unit, min, max)
	if  UnitIsDead(unit) or UnitIsGhost(unit) then
		Health:SetValue(0)
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
	local castbar = F.CreateStatusBar(self, nil, nil, nil, nil, .35, .35, .35, 1, 'oUF_LynCastbarTarget')
	F.ApplyBD(castbar)
		
	local castbarSpark = castbar:CreateTexture(nil,'OVERLAY')
	castbarSpark:SetBlendMode('Add')
	castbarSpark:SetHeight(castbar:GetHeight() * 2.3)
	castbarSpark:SetWidth(10)
	castbarSpark:SetVertexColor(1, 1, 1)
	castbar.Spark = castbarSpark

	local castbarText = F.CreateFS(castbar, 'LEFT', 'OVERLAY')
	castbarText:SetPoint('LEFT', castbar, 'LEFT', 5, 0)
	castbar.Text = castbarText
	
	local castbarTime = F.CreateFS(castbar, 'RIGHT', 'OVERLAY', C.FONTBIG, 18)
	castbarTime:SetPoint('RIGHT', castbar, 'RIGHT', -5, 0)
	castbar.Time = castbarTime
		
	if unit == 'target' then
		castbar:SetHeight(24)
		castbar:SetWidth(300)
		castbar:SetPoint("BOTTOM", self, "TOP", 0, 175)
	elseif unit == 'player' then
		castbar:SetHeight(25)
		castbar:SetWidth(self:GetWidth())
		castbar:SetPoint("BOTTOM", self, "TOP", 0, 100)
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
	
	self:SetWidth(150)
	self:SetHeight(25)
	F.ApplyBD(self)
	
	local Health = F.CreateStatusBar(self, nil, nil, nil, nil, 1, 0, 0, 1)
	Health:SetPoint('TOP')
	Health:SetPoint('LEFT')
	Health:SetPoint('RIGHT')

	Health.frequentUpdates = true
	Health.Smooth = true

	self.Health = Health

	local HealthPoints = F.CreateFS(self.Health, 'RIGHT', 'OVERLAY', C.FONTBIG, 20)
	HealthPoints:SetPoint('RIGHT', Health, -2, 0)
	self:Tag(HealthPoints, '[lyn:health]')

	Health.value = HealthPoints


	Health.PostUpdate = PostUpdateHealth
end

local UnitSpecific = {
	player = function(self, ...)
		Shared(self, ...)
		self:SetWidth(426)
		self:SetHeight(45)
		
		local hpText = self.Health.value
		hpText:SetFont(FONTBIG, 22, 'OUTLINE')
		self:Tag(hpText, '[lyn:hpp]')		
		self.Health.value = hpText
		
		local powerText = F.CreateFS(self.Health, 'CENTER', 'OVERLAY', C.FONTBIG, 36)
		powerText:SetPoint('CENTER', self.Health)
		self:Tag(powerText, '[lyn:power]')
		
		local pvp =  F.CreateFS(self.Health, 'LEFT', 'OVERLAY', C.FONTBIG, 20)
		pvp:SetPoint('TOPLEFT', self, -2, 8)
		self:Tag(pvp, '[lyn:targetpvp]')
		
		CreateCastbar(self, 'player')
	end,
	target = function(self, ...)
		Shared(self, ...)
		self:SetWidth(426)
		self:SetHeight(30)
		
		local name = F.CreateFS(self.Health, 'LEFT', 'OVERLAY')
		name:SetPoint("LEFT", self.Health, 2, 0)
		name:SetWidth(360)
		self.Name = name
		self:Tag(self.Name, '[lyn:color][lyn:targetname]')
		
		local classification = F.CreateFS(self.Health, 'RIGHT', 'OVERLAY')
		classification:SetPoint('BOTTOM', self.Health, 'TOP', 0, -4)
		classification:SetHeight(10)
		self:Tag(classification, '[lyn:classification]')
		
		local quest = F.CreateFS(self.Health, 'RIGHT', 'OVERLAY')
		quest:SetPoint('RIGHT', classification, 'LEFT', -1, -1)
		quest:SetText('|cffffe400QUESTMOB|r')
		self.QuestIcon = quest
		
		CreateCastbar(self, 'target')
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
	spawnHelper(self, 'player', 'BOTTOM', 0, 250)
	spawnHelper(self, 'target', 'BOTTOM', oUF_CaistealPlayer, 'TOP', 0, 10)
	spawnHelper(self, 'targettarget', 'BOTTOMRIGHT', oUF_CaistealTarget, 'TOPRIGHT', 0, 10)
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
	