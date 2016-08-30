local F, C = unpack(select(2, ...))

local r, g, b  = 103/255, 103/255, 103/255
local _, class = UnitClass'player'
local colour   = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
local TEXTURE  = [[Interface\AddOns\Caisteal\media\textures\Skullflower.tga]]
local FONT	   = [[C.FONT]]

-- hook functions
local AddProgressBarHook = function(self, block, line)
	local pBar = line.ProgressBar
	
	if pBar then		
		local _, anchor = pBar:GetPoint()
		anchor = anchor or block.currentLine or block.HeaderText
 
		pBar:ClearAllPoints()
		pBar:SetSize(ObjectiveTrackerBlocksFrame:GetWidth(), 20)
		pBar:SetPoint("TOP", anchor, "BOTTOM", 0, -15)
		pBar:SetPoint("LEFT", ObjectiveTrackerBlocksFrame, "LEFT", 0, 0)
	
		if not pBar.skinned then
			pBar.Bar:SetHeight(14)
			pBar.Bar:SetStatusBarTexture(TEXTURE)
			
			local bg = pBar:CreateTexture(nil, 'BORDER')
			bg:SetPoint('TOPLEFT', pBar.Bar, -1, 1)
			bg:SetPoint('BOTTOMRIGHT', pBar.Bar, 1, -1)
			bg:SetTexture([[Interface/Buttons/WHITE8X8]])
			bg:SetVertexColor(0,0,0,1)
				
			local trans = CreateFrame('Frame', nil, pBar.Bar)
			trans:SetBackdrop({
				bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
				tiled = false,
				insets = {left = -3, right = -3, top = -3, bottom = -3}
			})
			trans:SetAllPoints(pBar.Bar)
			trans:SetFrameLevel(0)
			trans:SetFrameStrata('BACKGROUND')
			trans:SetBackdropColor(0, 0, 0, 0.6)

			if pBar.Bar.BorderLeft then
				pBar.Bar.BorderLeft:SetAlpha(0)
				pBar.Bar.BorderRight:SetAlpha(0)
				pBar.Bar.BorderMid:SetAlpha(0)
			end
			
			if pBar.Bar.BarFrame then
				for _, v in pairs({pBar.Bar.BarFrame, pBar.Bar.Icon, pBar.Bar.IconBG}) do
					v:SetAlpha(0)
				end
			end

			pBar.Bar.Label:SetFont(FONT, 11, 'OUTLINE')
			pBar.Bar.Label:SetShadowOffset(1, -1)
			pBar.Bar.Label:SetShadowColor(0, 0, 0)
			pBar.Bar.Label:SetJustifyH'CENTER'
			pBar.Bar.Label:ClearAllPoints()
			pBar.Bar.Label:SetPoint('CENTER', pBar.Bar, 2, 0)
			pBar.Bar.Label:SetDrawLayer('OVERLAY', 7)

			pBar.skinned = true
		end
	end
end

local AddTimerBarHook = function(self, block, line, duration, startTime)
	local tb = self.usedTimerBars[block] and self.usedTimerBars[block][line]
	if tb and tb:IsShown() then
	
		local _, anchor = pBar:GetPoint()
		anchor = anchor or block.currentLine or block.HeaderText
 
		pBar:ClearAllPoints()
		pBar:SetSize(ObjectiveTrackerBlocksFrame:GetWidth(), 20)
		pBar:SetPoint("TOP", anchor, "BOTTOM", 0, -15)
		pBar:SetPoint("LEFT", ObjectiveTrackerBlocksFrame, "LEFT", 0, 0)
	
		if not tb.skinned then
			tb.Bar:SetStatusBarTexture(TEXTURE)
			tb.skinned = true
		end
	end
end

local AutoQuestPopupHook = function() -- works
	local pop = GetNumAutoQuestPopUps()
	for i = 1, pop do
		local questID, popUpType = GetAutoQuestPopUp(i)
		local questTitle 		 = GetQuestLogTitle(GetQuestLogIndexByID(questID))
		
		if questTitle and questTitle ~= '' then
			local block = AUTO_QUEST_POPUP_TRACKER_MODULE:GetBlock(questID)
		
			if block then
				local blockframe = block.ScrollChild
			
				if not blockframe.bu then
					local bu = CreateFrame('Frame', nil, blockframe)
					bu:SetPoint('TOPLEFT', blockframe, 50, 0)
					bu:SetPoint('BOTTOMRIGHT', blockframe, 0, 0)
					bu:SetBackdrop({
						bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
						tiled = false,
						insets = {left = -3, right = -3, top = -3, bottom = -3}
					})
					bu:SetBackdropColor(0, 0, 0, 1)
					bu:SetFrameLevel(0)
					blockframe.bu = bu
					
					blockframe.FlashFrame.IconFlash:SetAlpha(0)
					
					 if popUpType == 'COMPLETE' then
						blockframe.QuestIconBg:SetAlpha(0)
						blockframe.QuestIconBadgeBorder:SetAlpha(0)

						blockframe.QuestionMark:ClearAllPoints()
						blockframe.QuestionMark:SetPoint('CENTER', bu, 'LEFT', 10, 0)
						blockframe.QuestionMark:SetParent(bu)
						blockframe.QuestionMark:SetDrawLayer('OVERLAY', 7)
						blockframe.IconShine:SetAlpha(0)
					elseif popUpType == 'OFFER' then
						blockframe.QuestIconBg:SetAlpha(0)
						blockframe.QuestIconBadgeBorder:SetAlpha(0)

						blockframe.Exclamation:ClearAllPoints()
						blockframe.Exclamation:SetPoint('CENTER', bu, 'LEFT', 10, 0)
						blockframe.Exclamation:SetParent(bu)
						blockframe.Exclamation:SetDrawLayer('OVERLAY', 7)
					end
					
					blockframe.FlashFrame:SetAlpha(0)
					blockframe.Bg:SetAlpha(0)
					for _, v in pairs({
						blockframe.BorderTopLeft, blockframe.BorderTopRight, blockframe.BorderBotLeft, blockframe.BorderBotRight,
						blockframe.BorderLeft,    blockframe.BorderRight,    blockframe.BorderTop,     blockframe.BorderBottom}) do
						v:SetAlpha(0)
					end

				end
			end
		end
	end
end

local QuestObjectiveItemInitHook = function(button) 
	if button and not button.skinned then		
		button:SetNormalTexture([[Interface/AddOns/Lyn/assets/border.tga]])
		button:SetPushedTexture([[Interface/AddOns/Lyn/assets/border.tga]])
		
		button:SetSize(24, 24)
		button:SetBackdrop({
			bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
			tiled = false,
			insets = {left = -3, right = -3, top = -3, bottom = -3}
		})
		button:SetBackdropColor(0, 0, 0, .6)
		
		button.icon:SetTexCoord(.08, .92, .08, .92)
		
		local normal = button:GetNormalTexture()
		normal:SetPoint('TOPLEFT', -1, 1)
		normal:SetPoint('BOTTOMRIGHT', 1, -1)
		normal:SetVertexColor(0, 0, 0, 1)

		local pushed = button:GetPushedTexture()
		pushed:SetPoint('TOPLEFT', -1, 1)
		pushed:SetPoint('BOTTOMRIGHT', 1, -1)
		pushed:SetVertexColor(1, 1, 0, 1)
	
		button.skinned = true
	end
end

local ScenarioButtonHook = function()
	local block = ScenarioStageBlock
	local _, currentStage, numStages, flags = C_Scenario.GetInfo()

	block.NormalBG:SetTexture([[Interface\Tooltips\UI-Tooltip-Background]])
	block.NormalBG:SetVertexColor(0, 0, 0, 1)
	
	block.FinalBG:SetTexture('')	
	block.GlowTexture:SetTexture('')
	
	block.Stage:SetFont(FONT, 15)		
	block.Stage:ClearAllPoints()
	block.Stage:SetPoint('TOPLEFT', 15, -14)
end


-- initialize
if not ObjectiveTrackerFrame then
	UIParentLoadAddOn("Blizzard_ObjectiveTracker")
end

if not ObjectiveTrackerFrame.initialized then
	ObjectiveTracker_Initialize(ObjectiveTrackerFrame)
end
ObjectiveTracker_Update()
QuestSuperTracking_ChooseClosestQuest()
ObjectiveTrackerFrame.inMicroDungeon = IsPlayerInMicroDungeon()
AutoQuestPopupHook()

-- hook me up
hooksecurefunc("ObjectiveTracker_Update", function(reason, id)
	for i = 1, #ObjectiveTrackerFrame.MODULES do
		local module = ObjectiveTrackerFrame.MODULES[i]
		
		module.Header.Background:SetAtlas(nil)
		module.Header.Text:SetFont(FONT, 14)
		module.Header.Text:ClearAllPoints()
		module.Header.Text:SetPoint('RIGHT', module.Header, -62, 0)
		module.Header.Text:SetJustifyH'LEFT'
		module.Header.Text:SetTextColor(1, 1, 1)
		
		for _, block in pairs(module.usedBlocks) do
			if block.HeaderText then
				block.HeaderText:SetFont(FONT, 13)
				block.HeaderText:SetShadowOffset(.7, -.7)
				block.HeaderText:SetShadowColor(0, 0, 0, 1)
			end
		
			for _, line in pairs(block.lines) do
				line.Text:SetFont([[Fonts/ARIALN.ttf]], 12)
				line.Text:SetShadowOffset(.7, -.7)
				line.Text:SetShadowColor(0, 0, 0, 1)
			end
		end
		
	end
end)

for i = 1, #ObjectiveTrackerFrame.MODULES do
	local module = ObjectiveTrackerFrame.MODULES[i]
	
	if module.AddProgressBar ~= DEFAULT_OBJECTIVE_TRACKER_MODULE.AddProgressBar then
		hooksecurefunc(module, 'AddProgressBar', AddProgressBarHook)
	end
			
	if module.AddTimerBar ~= DEFAULT_OBJECTIVE_TRACKER_MODULE.AddTimerBar then
		hooksecurefunc(module, 'AddTimerBar', AddTimerBarHook)
	end
						
	if module == AUTO_QUEST_POPUP_TRACKER_MODULE then
		hooksecurefunc(module, 'Update', AutoQuestPopupHook)
	end
			
	if module == SCENARIO_CONTENT_TRACKER_MODULE then
		hooksecurefunc(module, 'Update', ScenarioButtonHook)
	end
end

hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, 'AddProgressBar', AddProgressBarHook)
hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, 'AddTimerBar', AddTimerBarHook)

hooksecurefunc(SCENARIO_TRACKER_MODULE, 'AddProgressBar', AddProgressBarHook)

hooksecurefunc('ScenarioBlocksFrame_OnLoad', ScenarioButtonHook)
hooksecurefunc('QuestObjectiveItem_Initialize', QuestObjectiveItemInitHook)

local handler = CreateFrame'Frame'
handler:RegisterEvent'ADDON_LOADED'
handler:RegisterEvent'QUEST_AUTOCOMPLETE'
handler:RegisterEvent'QUEST_LOG_UPDATE'
handler:SetScript('OnEvent', function(self, event, addon)
	if addon == 'Blizzard_ObjectiveTracker' then
		ScenarioButtonHook()
		self:UnregisterEvent('ADDON_LOADED')
	end
end)
	
-- move
-- http://www.wowinterface.com/forums/showthread.php?t=50666
local moving
hooksecurefunc(ObjectiveTrackerFrame, 'SetPoint', function(self)
	if moving then return end
	moving = true
	self:SetMovable(true)
	self:SetUserPlaced(true)
	self:ClearAllPoints()
	--self:SetPoint('TOPRIGHT', UIParent, -50, -275)
	self:SetPoint('TOPRIGHT', UIParent, -50, -245)
	self:SetParent(Minimap) -- Only for default Blizzard unitframes.
	self:SetMovable(false)
	self:SetHeight(600)
	moving = nil
end)

-- misc styling options	
local min = ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
min:SetSize(15, 15)
min:SetNormalTexture''
min:SetPushedTexture''

min.minus = min:CreateFontString(nil, 'OVERLAY')
min.minus:SetFont(FONT, 14)
min.minus:SetText'-'
min.minus:SetSize(16,16)
min.minus:SetPoint('CENTER', min, 0, 1)
min.minus:SetTextColor(1, 1, 1)
min.minus:SetShadowOffset(.7, -.7)
min.minus:SetShadowColor(0, 0, 0, 1)

min.plus = min:CreateFontString(nil, 'OVERLAY')
min.plus:SetFont(FONT, 14)
min.plus:SetText'+'
min.plus:SetSize(16,16)
min.plus:SetPoint('CENTER', min, 0, 1)
min.plus:SetTextColor(1, 1, 1)
min.plus:SetShadowOffset(.7, -.7)
min.plus:SetShadowColor(0, 0, 0, 1)
min.plus:Hide()
		
ObjectiveTrackerFrame.HeaderMenu.Title:SetFont(FONT, 14)
ObjectiveTrackerFrame.HeaderMenu.Title:SetTextColor(1, 1, 1)

min:HookScript('OnEnter', function() 
	min.minus:SetTextColor(.7, .5, 0) 
	min.plus:SetTextColor(.7, .5, 0) 
end)

min:HookScript('OnLeave', function() 
	min.minus:SetTextColor(1, 1, 1) 
	min.plus:SetTextColor(1, 1, 1) 
end)

hooksecurefunc('ObjectiveTracker_Collapse', function() 
	ObjectiveTrackerFrame.HeaderMenu.Title:SetFont(FONT, 14)
	ObjectiveTrackerFrame.HeaderMenu.Title:SetTextColor(1, 1, 1)
	min.plus:Show()
end)

hooksecurefunc('ObjectiveTracker_Expand', function()
	min.plus:Hide()
end)

-- if _G['ObjectiveTrackerBlocksFrameHeader'] then
	-- _G['ObjectiveTrackerBlocksFrameHeader']:SetTextColor(1, 1, 1)
-- end

local bck_WorldMapFrame_OnHide = WorldMapFrame:GetScript("OnHide")
WorldMapFrame:SetScript("OnHide", function(self)
	if InCombatLockdown() then
		self.UIElementsFrame.ActionButton.mapAreaID = nil
	end
	bck_WorldMapFrame_OnHide(self)
end)
	

