function rmbang ($bang) {
    $RmAPI.Bang($bang)
}
rmbang "[!SetOption AppName_BackGround_App1 Y `"(10*#Scale#+#Scroll#)r`"][!SetOption Shortcut1.Image X `"(5*#Scale#)`"][!SetOption Shortcut1.Image Y `"(10*#Scale#+#Scroll_2#)`"][!SetOption Shortcut6.Image X `"(5*#Scale#)`"][!SetOption Shortcut6.Image Y `"(60*#Scale#)r`"][!SetOption Shortcut11.Image X `"(5*#Scale#)`"][!SetOption Shortcut11.Image Y `"(60*#Scale#)r`"][!SetOption Shortcut16.Image X `"(5*#Scale#)`"][!SetOption Shortcut16.Image Y `"(60*#Scale#)r`"][!SetOption Shortcut21.Image X `"(5*#Scale#)`"][!SetOption Shortcut21.Image Y `"(60*#Scale#)r`"][!SetOption Shortcut26.Image X `"(5*#Scale#)`"][!SetOption Shortcut26.Image Y `"(60*#Scale#)r`"][!SetOption Shortcut31.Image X `"(5*#Scale#)`"][!SetOption Shortcut31.Image Y `"(60*#Scale#)r`"][!SetOption Shortcut36.Image X `"(5*#Scale#)`"][!SetOption Shortcut36.Image Y `"(60*#Scale#)r`"][!SetOption Shortcut41.Image X `"(5*#Scale#)`"][!SetOption Shortcut41.Image Y `"(60*#Scale#)r`"][!SetOption Shortcut46.Image X `"(5*#Scale#)`"][!SetOption Shortcut46.Image Y `"(60*#Scale#)r`"][!SetOption Shortcut51.Image X `"(5*#Scale#)`"][!SetOption Shortcut51.Image Y `"(60*#Scale#)r`"][!UpdateMeter *][!Redraw]"


#================================================================================================================================#
#                                                        Commands                                                                #
#================================================================================================================================#
function search_start {
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class Keyboard {
        [DllImport("user32.dll", CharSet = CharSet.Auto, ExactSpelling = true)]
        public static extern void keybd_event(byte bVk, byte bScan, int dwFlags, int extraInfo);
        public const int KEYEVENTF_EXTENDEDKEY = 0x1;
        public const int KEYEVENTF_KEYUP = 0x2;
        public const int VK_LWIN = 0x5B;
        public const int VK_S = 0x53;
    }
"@

    # Simulate Win + S key press
    [Keyboard]::keybd_event([Keyboard]::VK_LWIN, 0, [Keyboard]::KEYEVENTF_EXTENDEDKEY, 0)   # Press Win key
    [Keyboard]::keybd_event([Keyboard]::VK_S, 0, [Keyboard]::KEYEVENTF_EXTENDEDKEY, 0)       # Press S key

    # Simulate key release
    [Keyboard]::keybd_event([Keyboard]::VK_S, 0, [Keyboard]::KEYEVENTF_KEYUP, 0)             # Release S key
    [Keyboard]::keybd_event([Keyboard]::VK_LWIN, 0, [Keyboard]::KEYEVENTF_KEYUP, 0)          # Release Win key
}

