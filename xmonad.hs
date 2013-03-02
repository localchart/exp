import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig
import System.IO
import qualified XMonad.StackSet as W
import XMonad.Actions.GridSelect

myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0" ]

main = do
  xmproc <- spawnPipe "exec xmobarj ~/.xmobarrc"
  xmonad $ defaultConfig
       { manageHook = manageDocks <+> manageHook defaultConfig,
         layoutHook = avoidStruts $ layoutHook defaultConfig,
         logHook = dynamicLogWithPP xmobarPP
                   { ppOutput = hPutStrLn xmproc,
                     ppCurrent = xmobarColor "#cb4b16" "" . wrap "[" "]",
                     ppTitle = xmobarColor "#93a1a1" "" . shorten 70 },
         modMask = mod4Mask,
         borderWidth = 1,
         workspaces = myWorkspaces, 
         terminal = "urxvtc -e screen -UxS lightning",
         normalBorderColor = "#ffffff",
         focusedBorderColor = "#073642" }
       `additionalKeys`
       [((m .|. mod4Mask, k), windows $ f i)
        | (i, k) <- zip myWorkspaces ([xK_1 .. xK_9] ++ [xK_0])
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
       `additionalKeysP`       
       [ ("M4-;", spawn "jpn-on"),
         ("M4-'", spawn "jpn-off"),
         ("M4-S-z", spawn "gnome-screensaver-command --lock"),
         ("M4-<Space>", spawn "exec dmenu.sh"),
         ("M4-`", sendMessage NextLayout),
         ("M4-S-w", spawn "exec conkeror -new chrome://"),
         ("M4-S-e", spawn "exec emacsclient -nc"),
         ("M4-S--", sendMessage Shrink),
         ("M4-S-=", sendMessage Expand),
         ("M4-S-t", withFocused $ windows . W.sink),
         ("M4-<Esc>", spawn "xmonad --recompile && xmonad --restart"),
         ("<XF86MonBrightnessDown>", spawn "brightness down"),
         ("<XF86MonBrightnessUp>", spawn "brightness up"),
         ("<XF86LaunchA>", goToSelected defaultGSConfig),
         ("<XF86LaunchB>", spawnSelected defaultGSConfig 
                            ["netcfgd home","netcfgd cs",
                             "killall workrave", "workrave"]),
         ("<XF86KbdBrightnessDown>", spawn "kbd_brightness off"),
         ("<XF86KbdBrightnessUp>", spawn "kbd_brightness on"),
         ("<XF86AudioPrev>", spawn "fnkey prev"),
         ("<XF86AudioPlay>", spawn "fnkey play"),
         ("<XF86AudioNext>", spawn "fnkey next"),
         ("<XF86AudioMute>", spawn "volume mute"),
         ("<XF86AudioLowerVolume>", spawn "volume down"),
         ("<XF86AudioRaiseVolume>", spawn "volume up"),
         ("<XF86PowerOff>", spawn "xlock -delay 20000 -usefirst")
       ]
       `removeKeysP`
       [ "M4-r", "M4-n", "M4-w", "M4-p", "M4-q", "M4-t", "M4-l", "M4-h", "M4-S-q" ]
                                          
