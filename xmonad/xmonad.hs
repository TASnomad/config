import Data.Char (isSpace, toUpper)
import Data.Maybe (fromJust, isJust)
import qualified Data.Map as M
import Data.Monoid
import Data.Tree
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)

import XMonad
-- XMonad is configure by default to use qwerty keyboards
-- The next line tells XMonad to use azerty instead
import XMonad.Config.Azerty

-- Actions
import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.CycleWS (Direction1D(..), moveTo, shiftTo, WSType(..), nextScreen, prevScreen, toggleWS, toggleWS')
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import qualified XMonad.Actions.Search as S
import qualified XMonad.StackSet as W

-- Prompts
import XMonad.Prompt
import XMonad.Prompt.Input
import XMonad.Prompt.FuzzyMatch
import XMonad.Prompt.XMonad
import XMonad.Prompt.Shell
import XMonad.Prompt.Man
import Control.Arrow (first)

-- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory

-- Layouts
import XMonad.Layout.Accordion
import XMonad.Layout.BinarySpacePartition
import XMonad.Layout.Gaps
import XMonad.Layout.NoFrillsDecoration
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns

-- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))


-- Utilities
import XMonad.Util.Dmenu
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce

myFont :: String
myFont = "xft:Fira Code Nerd Font:regular:size=12:antialias=true:hinting=true"

myModMask :: KeyMask
myModMask = mod4Mask

myTerminal :: String
myTerminal = "alacritty"

myBrowser :: String
myBrowser = "firefox"

myBorderWidth :: Dimension
myBorderWidth = 2

myNormColor :: String
myNormColor = "#2E3440"

myFocusColor :: String
myFocusColor = "#8FBCBB"

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myStartupHook :: X ()
myStartupHook = do
  spawnOnce "picom --config ~/config/picom.conf &"
  spawnOnce "nm-applet &"
  spawnOnce "blueman-tray &"
  spawnOnce "volumeicon &"
  spawnOnce "dunst -c ~/.config/dunst/dunstrc &"
  -- spawnOnce "redshift-gtk &"
  spawnOnce "xfce4-power-manager &"
  spawnOnce "xscreensaver -no-splash &"
  spawnOnce "/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &"
  spawnOnce "nitrogen --restore &"
  spawnOnce "xsetroot -cursor_name left_ptr"
  spawnOnce "trayer --SetDockType true --edge top --align right --transparent true --width 5 --height 20 --tint 0x2E3440 &"
  setWMName "LG3D"

myColorizer :: Window -> Bool -> X (String, String)
myColorizer = colorRangeFromClassName
                  (0x28,0x2c,0x34) -- lowest inactive bg
                  (0x28,0x2c,0x34) -- highest inactive bg
                  (0xc7,0x92,0xea) -- active bg
                  (0xc0,0xa7,0x9a) -- inactive fg
                  (0x28,0x2c,0x34) -- active fg

mygridConfig :: p -> GSConfig Window
mygridConfig colorizer = (buildDefaultGSConfig myColorizer)
    { gs_cellheight   = 40
    , gs_cellwidth    = 200
    , gs_cellpadding  = 6
    , gs_originFractX = 0.5
    , gs_originFractY = 0.5
    , gs_font         = myFont
    }

spawnSelected' :: [(String, String)] -> X ()
spawnSelected' lst = gridselect conf lst >>= flip whenJust spawn
    where conf = def
                   { gs_cellheight   = 40
                   , gs_cellwidth    = 200
                   , gs_cellpadding  = 6
                   , gs_originFractX = 0.5
                   , gs_originFractY = 0.5
                   , gs_font         = myFont
                   }

myScratchPads :: [NamedScratchpad]
myScratchPads = [ NS "terminal" spawnTerm findTerm manageTerm
                , NS "htop" spawnHtop findHtop manageHtop
                , NS "calculator" spawnCalc findCalc manageCalc
                , NS "mixer" spawnMixer findMixer manageMixer
                ]
  where
    spawnMixer = myTerminal ++ " -t mixer -e alsamixer"
    findMixer  = title =? "mixer"
    manageMixer = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
    spawnTerm  = myTerminal ++ " -t scratchpad"
    findTerm   = title =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
    spawnHtop  = myTerminal ++ " -t htop -e htop"
    findHtop   = title =? "htop"
    manageHtop = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
    spawnCalc  = "qalculate-gtk"
    findCalc   = className =? "Qalculate-gtk"
    manageCalc = customFloating $ W.RationalRect l t w h
               where
                 h = 0.5
                 w = 0.4
                 t = 0.75 -h
                 l = 0.70 -w

--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Defining a bunch of layouts, many that I don't use.
-- limitWindows n sets maximum number of windows displayed for layout.
-- mySpacing n sets the gap size around the windows.
tall     = renamed [Replace "tall"]
           $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 4
           $ ResizableTall 1 (3/100) (1/2) []
magnify  = renamed [Replace "magnify"]
           $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ magnifier
           $ limitWindows 12
           $ mySpacing 4
           $ ResizableTall 1 (3/100) (1/2) []
monocle  = renamed [Replace "monocle"]
           $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 20 Full
floats   = renamed [Replace "floats"]
           $ smartBorders
           $ limitWindows 20 simplestFloat
grid     = renamed [Replace "grid"]
           $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 4
           $ mkToggle (single MIRROR)
           $ Grid (16/10)
spirals  = renamed [Replace "spirals"]
           $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ mySpacing' 4
           $ spiral (6/7)
threeCol = renamed [Replace "threeCol"]
           $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 7
           $ ThreeCol 1 (3/100) (1/2)
threeRow = renamed [Replace "threeRow"]
           $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 7
           -- Mirror takes a layout and rotates it by 90 degrees.
           -- So we are applying Mirror to the ThreeCol layout.
           $ Mirror
           $ ThreeCol 1 (3/100) (1/2)
tabs     = renamed [Replace "tabs"]
           -- I cannot add spacing to this layout because it will
           -- add spacing between window and tabs which looks bad.
           $ tabbed shrinkText myTabTheme
tallAccordion  = renamed [Replace "tallAccordion"]
           $ Accordion
wideAccordion  = renamed [Replace "wideAccordion"]
           $ Mirror Accordion

-- setting colors for tabs layout and tabs sublayout.
myTabTheme = def { fontName            = myFont
                 , activeColor         = "#8FBCBB"
                 , inactiveColor       = "#3B4252"
                 , activeBorderColor   = "#88C0D0"
                 , inactiveBorderColor = "#2E3440"
                 , activeTextColor     = "#2E3440"
                 , inactiveTextColor   = "#D8DEE9"
                 }

-- The layout hook
myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats
               $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
             where
               myDefaultLayout =     withBorder myBorderWidth emptyBSP
                                 ||| tall
                                 ||| magnify
                                 ||| noBorders monocle
                                 ||| floats
                                 ||| noBorders tabs
                                 ||| grid
                                 ||| spirals
                                 ||| threeCol
                                 ||| threeRow
                                 ||| tallAccordion
                                 ||| wideAccordion

myWorkspaces = [" 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 "]
myWorkspaceIndices = M.fromList $ zip myWorkspaces [1..] -- (,) == \x y -> (x,y)

clickable ws = "<action=xdotool key super+" ++ show i ++ ">" ++ ws ++ "</action>"
   where i = fromJust $ M.lookup ws myWorkspaceIndices

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
     -- 'doFloat' forces a window to float.  Useful for dialog boxes and such.
     -- using 'doShift ( myWorkspaces !! 7)' sends program to workspace 8!
     -- I'm doing it this way because otherwise I would have to write out the full
     -- name of my workspaces and the names would be very long if using clickable workspaces.
     [ className =? "confirm"         --> doFloat
     , className =? "file_progress"   --> doFloat
     , className =? "dialog"          --> doFloat
     , className =? "download"        --> doFloat
     , className =? "error"           --> doFloat
     , className =? "Gimp"            --> doFloat
     , className =? "notification"    --> doFloat
     , className =? "pinentry-gtk-2"  --> doFloat
     , className =? "splash"          --> doFloat
     , className =? "toolbar"         --> doFloat
     , title =? "Oracle VM VirtualBox Manager"  --> doFloat
     , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
     , isFullscreen -->  doFullFloat
     ] <+> namedScratchpadManageHook myScratchPads

systemPromptCmds = [
       ("Exit", io exitSuccess),
       ("Lock", spawn "xscreensaver-command -lock"),
       ("Reboot", spawn "reboot"),
       ("Restart", restart "xmonad" True),
       ("Shutdown", spawn "poweroff")
    ]

exitPromptxKb :: M.Map (KeyMask,KeySym) (XP ())
exitPromptxKb = M.fromList $
    map (first $ (,) controlMask)
    [ (xK_u, killBefore)
    ]
    ++
    map (first $ (,) 0)
    [ (xK_Return, setSuccess True >> setDone True)
    , (xK_KP_Enter, setSuccess True >> setDone True)
    , (xK_BackSpace, deleteString Prev)
    , (xK_Delete, deleteString Next)
    , (xK_q, quit)
    , (xK_Escape, quit)
    ]

exitPromptXPConfig :: XPConfig
exitPromptXPConfig = def
    { font = myFont
    , bgColor = "#2E3440"
    , fgColor = "#D8DEE9"
    , bgHLight = "#8FBCBB"
    , fgHLight = "#000000"
    , borderColor = "#BF616A"
    , promptBorderWidth = 4
    , promptKeymap = vimLikeXPKeymap
    -- , promptKeymap = exitPromptXPConfig
    , position = CenteredAt 0.5 0.5 -- Centered
    , height = 50
    , historySize = 256
    , defaultText = []
    , showCompletionOnTab = True
    , searchPredicate = fuzzyMatch
    , alwaysHighlight = True
    , maxComplRows = Nothing
    }

runnerPromptXPConfig :: XPConfig
runnerPromptXPConfig = def
    { font = myFont
    , bgColor = "#2E3440"
    , fgColor = "#D8DEE9"
    , bgHLight = "#8FBCBB"
    , fgHLight = "#000000"
    , borderColor = "#88C0D0"
    , promptBorderWidth = 4
    , promptKeymap = vimLikeXPKeymap
    , position = CenteredAt 0.1 0.5
    , height = 50
    , historySize = 256
    , defaultText = []
    , showCompletionOnTab = True
    , searchPredicate = fuzzyMatch
    , alwaysHighlight = True
    , maxComplRows = Just 15
    }

myKeys :: [(String, X ())]
myKeys =
        [ ("M-C-r", spawn "xmonad --recompile")  -- Recompiles xmonad
        , ("M-S-r", spawn "xmonad --restart")    -- Restarts xmonad
        , ("M-S-q", io exitSuccess)
        -- , ("M-S-q", xmonadPromptC systemPromptCmds exitPromptXPConfig)
        , ("M-S-<Return>", spawn "dmenu_run -c -l 20 -F -i -fn 'Fira Code Nerd Font:bold:size=13'")
        -- , ("M-S-<Return>", shellPrompt runnerPromptXPConfig)
        , ("M-<Return>", spawn myTerminal)
        , ("M-M1-k", manPrompt runnerPromptXPConfig)
        , ("M-S-c", kill)
        , ("C-M1-<Delete>", spawn "xscreensaver-command -lock")
        , ("M-f", sendMessage (T.Toggle "floats"))
        , ("M-t", withFocused $ windows . W.sink)
        , ("M-j", windows W.focusDown)
        , ("M-k", windows W.focusUp)
        , ("M-S-<Tab>", sendMessage NextLayout)
        , ("M-S-<Space>", sendMessage (ToggleStruts))
        , ("M-<Space>", sendMessage (MT.Toggle NBFULL))
        , ("M-<Tab>", toggleWS' ["NSP"]) -- Switch ws back & forth (ignoring scratchpads)
        , ("M-S-<F1>", spawn "firefox")
        , ("M-S-<F2>", spawn "pcmanfm")
        , ("M-S-<F3>", namedScratchpadAction myScratchPads "terminal")
        , ("M-S-<F4>", namedScratchpadAction myScratchPads "htop")
        , ("M-S-<F5>", namedScratchpadAction myScratchPads "calculator")
        , ("M-S-<F6>", namedScratchpadAction myScratchPads "mixer")
        , ("<XF86AudioPlay>", spawn "playerctl play-pause")
        , ("<XF86AudioNext>", spawn "playerctl next")
        , ("<XF86AudioPrev>", spawn "playerctl previous")
        , ("<XF86AudioStop>", spawn "playerctl stop")
        , ("<XF86AudioLowerVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ -10%")
        , ("<XF86AudioRaiseVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ +10%")
        , ("<XF86AudioMicMute>", spawn "pactl set-source-mute @DEFAULT_SOURCE@ toggle")
        , ("<XF86AudioMute>", spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")
        , ("<XF86MonBrightnessDown>", spawn "xbacklight -dec 10")
        , ("<XF86MonBrightnessUp>", spawn "xbacklight -inc 10")
        ]
          where nonNSP          = WSIs (return (\ws -> W.tag ws /= "NSP"))
                nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "NSP"))

main :: IO ()
main = do
     xmproc <- spawnPipe "xmobar -d ~/config/xmobar/xmobarrc"
     xmonad $ ewmh def
        { manageHook            = myManageHook <+> manageDocks
        , handleEventHook       = docksEventHook <+> fullscreenEventHook
        , modMask               = myModMask
        , terminal              = myTerminal
        , startupHook           = myStartupHook
        , layoutHook            = myLayoutHook
        , workspaces            = myWorkspaces
        , borderWidth           = myBorderWidth
        , normalBorderColor     = myNormColor
        , focusedBorderColor    = myFocusColor
        , focusFollowsMouse     = myFocusFollowsMouse
        , keys                  = azertyKeys
        , logHook               = dynamicLogWithPP $ namedScratchpadFilterOutWorkspacePP $ xmobarPP
              -- TODO handle multimonitor
              { ppOutput = hPutStrLn xmproc
              , ppCurrent = xmobarColor "#88C0D0" "" . wrap "[" "]"
              , ppVisible = xmobarColor "#88C0D0" "" . clickable
              , ppHidden = xmobarColor "#5E81AC" "" . wrap "*" "" . clickable
              , ppHiddenNoWindows = xmobarColor "#2E3440" "" . clickable
              , ppTitle = xmobarColor "#ECEFF4" "" . shorten 20
              , ppSep = "<fc=#66666> <fn=1>|</fn> </fc>"
              , ppUrgent = xmobarColor "#BF616A" "" . wrap "!" "!"
              , ppExtras = [windowCount]
              , ppOrder = \(ws:l:t:ex) -> [ws,l]++ex++[t]
              }
        } `additionalKeysP` myKeys
