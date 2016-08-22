local E, F, C = unpack(select(2, ...))

C.PlainTexture = [[Interface\ChatFrame\ChatFrameBackground]]
C.Texture = [[Interface\Addons\Caisteal\media\textures\Skullflower.tga]]

C.PlainBackdrop = {
	bgFile = C.PlainTexture,
	insets = {top = -1, bottom = -1, left = -1, right = -1}
}

C.EdgeBackdrop = {
	edgeFile = C.PlainTexture, 
	edgeSize = 1,
	insets = {top = 1, bottom = 1, left = 1, right = 1},
}

C.FONT =  [[Interface\Addons\Caisteal\media\fonts\Gotham.ttf]]
C.FONTBIG =  [[Interface\Addons\Caisteal\media\fonts\GothamNarrow.ttf]]
C.FONTDAMAGE =  [[Interface\Addons\Caisteal\media\fonts\Coalition.ttf]]

