function DropDown(variant, handler, offsetx,offsety)
	local saveLocation = SKIN:GetVariable('ROOTCONFIGPATH')..'DropDown\\Main.ini'
	local MyMeter = SKIN:GetMeter(handler)
	local scale = tonumber(SKIN:GetVariable('Scale'))
    local PosX = SKIN:GetX() + MyMeter:GetX() + offsetx * scale
    local PosY = SKIN:GetY() + MyMeter:GetY() + offsety * scale
    SKIN:Bang ('[!WriteKeyValue Variables variants ' .. variant .. ' "' .. saveLocation .. '"]')
	SKIN:Bang('!ZPos', '0')
	SKIN:Bang('!Activateconfig', 'YOurStart\\DropDown', 'Main.ini')
	SKIN:Bang('!Move', PosX, PosY, 'YOurStart\\DropDown')
end