function Initialize()

    -- ------------------------------- positioning ------------------------------ --

    pos = SKIN:GetVariable('Position')
    local function positionMenu()
        if pos == 'MousePosition' then
            MoveX = 0
            MoveY = 0
            AnchorX = '50%'
            AnchorY = '50%'
        elseif pos ~= 'Custom' then
            local posX = string.sub(pos, 2, 2)
            local posY = string.sub(pos, 1, 1)
            local xpad = SKIN:GetVariable('xpad')
            local ypad = SKIN:GetVariable('ypad')
            local MonitorIndex = SKIN:GetVariable('MonitorIndex')
            local taskbar = SKIN:GetVariable('PreserveTaskbarSpace')
            local sax = SKIN:GetVariable('SCREENAREAX@' .. MonitorIndex)
            local say = SKIN:GetVariable('SCREENAREAY@' .. MonitorIndex)
            local saw = SKIN:GetVariable('SCREENAREAWIDTH@' .. MonitorIndex)
            local sah = SKIN:GetVariable('SCREENAREAHEIGHT@' .. MonitorIndex)
            local waw = SKIN:GetVariable('WORKAREAWIDTH@' .. MonitorIndex)
            local wah = SKIN:GetVariable('WORKAREAHEIGHT@' .. MonitorIndex)
            local xdif = saw - waw
            local ydif = sah - wah
            MoveX = 0
            MoveY = 0
            AnchorX = 0
            AnchorY = 0

            if posX == 'L' then MoveX = (sax + xpad + taskbar * xdif)
            elseif posX == 'C' then
                MoveX = (sax + saw / 2)
                AnchorX = "50%"
            elseif posX == 'R' then
                MoveX = (sax + saw - xpad - taskbar * xdif)
                AnchorX = "100%"
            end

            if posY == 'T' then MoveY = (say + ypad + taskbar * ydif)
            elseif posY == 'C' then
                MoveY = (say + sah / 2)
                AnchorY = "50%"
            elseif posY == 'B' then
                MoveY = (say + sah - ypad - taskbar * ydif)
                AnchorY = "100%"
            end

            SKIN:Bang('!SetWindowPosition ' .. MoveX .. ' ' .. MoveY .. ' ' .. AnchorX .. ' ' .. AnchorY)
        end
    end
    positionMenu()

 
        

    -- ------------------------- handle animation toggle ------------------------ --

    if tonumber(SKIN:GetVariable('Animated')) == 1 then
        AniSteps = tonumber(SKIN:GetVariable('AniSteps'))
        TweenInterval = 100 / AniSteps
        AnimationDisplacement = SKIN:GetVariable('AnimationDisplacement')
        AniDir = SKIN:GetVariable('AniDir')
        dofile(SELF:GetOption("ScriptFile"):match("(.*[/\\])") .. "tween.lua")
        subject = {
            TweenNode = 0
        }
        t = tween.new(AniSteps, subject, { TweenNode = 100 }, SKIN:GetVariable('Easetype'))
    end
end


function tweenAnimation(dir)
    if dir == 'in' then
        t:update(1)
    else
        t:update(-1)
    end
    resultantTN = subject.TweenNode
    if resultantTN > 100 then resultantTN = 100 elseif resultantTN < 0 then resultantTN = 0 end
    local bang = '[!SetTransparency ' .. (resultantTN / 100 * 255) .. ']'
    if AniDir == 'Left' then
        bang = bang .. '[!SetWindowPosition ' .. MoveX + (resultantTN / 100 - 1) * AnimationDisplacement .. ' ' .. MoveY .. ' ' .. AnchorX .. ' ' .. AnchorY .. ']'
    elseif AniDir == 'Right' then
        bang = bang .. '[!SetWindowPosition ' .. MoveX + (1 - resultantTN / 100) * AnimationDisplacement .. ' ' .. MoveY .. ' ' .. AnchorX .. ' ' .. AnchorY .. ']'
    elseif AniDir == 'Top' then
        bang = bang .. '[!SetWindowPosition ' .. MoveX .. ' ' .. MoveY + (resultantTN / 100 - 1) * AnimationDisplacement .. ' ' .. AnchorX .. ' ' .. AnchorY .. ']'
    elseif AniDir == 'Bottom' then
        bang = bang .. '[!SetWindowPosition ' .. MoveX .. ' ' .. MoveY + (1 - resultantTN / 100) * AnimationDisplacement .. ' ' .. AnchorX .. ' ' .. AnchorY .. ']'
    end
    bang = bang .. '[!UpdateMeasure ActionTimer]'
    SKIN:Bang(bang)
    -- print(resultantTN)
end


function Popup(posX, posY)
    posX = posX + SKIN:GetX()
    posY = posY + SKIN:GetY()
    local saveLocation = SKIN:GetVariable('ROOTCONFIGPATH') .. 'Popup\\Main.ini'
    SKIN:Bang('[!WriteKeyValue Variables Skin.LastX ' .. posX .. ' "' .. saveLocation .. '"][!WriteKeyValue Variables Skin.LastY ' .. posY .. ' "' .. saveLocation .. '"][!ZPos 1][!DisableMeasure mToggleset][!Activateconfig "YourStart\\Popup"]')
end

