function CheckFullScreen()
    local MyMeasure = SKIN:GetMeasure('MeasureIsFullScreen')
    local mString = MyMeasure:GetStringValue()
    local mNum = MyMeasure:GetValue()
    local mBool = 0
    if mString:match('Rainmeter%.exe') then
        mBool = 1
    end
    local check = (mNum .. mBool)
    if string.match(check, '10') then
        SKIN:Bang('!Hide')
    else
        SKIN:Bang('!Show')
    end
end