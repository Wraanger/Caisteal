local F, C = unpack(select(2, ...))

local _, class = UnitClass('player')
local colour   = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]

F.dummy = function() end

F.BD = function(frame, a)
	local f = frame
	if frame:GetObjectType() == 'Texture' then f = frame:GetParent() end
	f:SetBackdrop(C.BACKDROP)
	f:SetBackdropColor(0, 0, 0, a or 0.5)
	f:SetBackdropBorderColor(0, 0, 0, a or 1)
end

F.CreateFS = function(parent, fontName, fontSize, justify)
	local f = parent:CreateFontString(nil, "OVERLAY")
	f:SetFont(fontName or C.FONT, fontSize or 14, 'OUTLINE')
	f:SetShadowColor(0, 0, 0)
	f:SetShadowOffset(1, -1)
	f:SetJustifyH(justify or 'LEFT')

    return f
end
F.SetFS = function(fontObject, fontSize)
	fontObject:SetFont(fontObject, fontSize or 14, 'OUTLINE')
	fontObject:SetShadowColor(0, 0, 0)
	fontObject:SetShadowOffset(1, -1)
end

F.CLASS_COLOR = function(f, a)
	if  f:GetObjectType() == 'StatusBar' then
		f:SetStatusBarColor(colour.r, colour.g, colour.b)
	elseif
		f:GetObjectType() == 'FontString' then
		f:SetTextColor(colour.r, colour.g, colour.b)
	else
		f:SetVertexColor(colour.r, colour.g, colour.b)
	end
end

F.SB = function(f)
	if  f:GetObjectType() == 'StatusBar' then
		f:SetStatusBarTexture(C.Texture)
	else
		f:SetTexture(C.Texture)
	end
end
