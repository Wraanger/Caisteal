local E, F, C = unpack(select(2, ...))

F.dummy = function() end

F.formatTime = function(s)
	local floor, fmod = floor, math.fmod
	local day, hour, minute = 86400, 3600, 60
	
    if s >= day then
        return format('%dd', floor(s/day + 0.5))
    elseif s >= hour then
        return format('%dh', floor(s/hour + 0.5))
    elseif s >= minute then
        return format('%dm', floor(s/minute + 0.5))
    end
    return format('%d', fmod(s, minute))
end

F.CreateFS = function(parent, justify, layer, fontName, fontSize, fontStyle)
	local fs = parent:CreateFontString(nil, layer or 'ARTWORK')
	fs:SetFont(fontName or C.FONT, fontSize or 15, fontStyle or 'OUTLINE')
	fs:SetShadowColor(0, 0, 0)
	fs:SetShadowOffset(1, -1)
	fs:SetJustifyH(justify or 'LEFT')
	
	return fs
end

F.CreateStatusBar = function(parent, r, g, b, a, r1, g1, b1, a1, name)
	local bar = CreateFrame('Statusbar', name or nil, parent)
	bar:SetStatusBarTexture(C.Texture)
	bar:SetStatusBarColor(r or 0.25, g or 0.25, b or 0.25, a or 1)
	
	local bg = bar:CreateTexture('$parentBackground', 'BORDER', bar)
	bg:SetTexture(C.Texture)
	bg:SetVertexColor(r1 or .35, g1 or .35, b1 or .35, a1 or 1)
	bg:SetAllPoints(bar)
	
	return bar
end

F.ApplyBD = function(frame, r, g, b, a)
	frame:SetBackdrop({
		bgFile = C.PlainTexture,
		insets = {top = -2, bottom = -2, left = -2, right = -2},
	})
	frame:SetBackdropColor(r or 0, g or 0, b or 0, a or 1)
end