{-# LANGUAGE FlexibleInstances, MultiParamTypeClasses, TypeSynonymInstances, FlexibleContexts, NoMonomorphismRestriction #-}

import Custom.MyTreeMenu

import XMonad hiding ( (|||) )
import Control.Monad.State
import Control.Monad (liftM2)
import Control.Concurrent (forkIO)
import Data.Tree
import Data.List -- (isInfixOf)
import Data.Char -- toLower, et al
import Data.Monoid -- toLower, et al
import           Data.Function               ((&))
import Data.Maybe (isNothing)
--import Text.Regex (matchRegex, mkRegex)
import qualified Data.Map                    as Map
import qualified XMonad.Util.ExtensibleState as XS
import qualified Data.Map as M
import qualified XMonad.Actions.Submap as SM
import qualified XMonad.Actions.Search as S
import qualified XMonad.Actions.WindowMenu as WindowMenu
import qualified XMonad.Actions.WindowBringer as WindowBringer
import qualified XMonad.StackSet as W -- (0a) window stack manipulation
import System.Directory                               -- for killall prompt, et al
import System.Exit
import System.IO
--import XMonad.Config.DescriptiveKeys
import XMonad.Actions.Submap
import XMonad.Actions.TopicSpace -- (22b) set a "topic" for each workspace
-- import qualified XMonad.Actions.TreeSelect as TS
import XMonad.Actions.CopyWindow
import XMonad.Actions.Commands
import XMonad.Actions.CycleRecentWS -- (17) cycle recent workspaces
import XMonad.Actions.CycleWS -- (16) general workspace-switching
import XMonad.Actions.DynamicWorkspaces -- (22c)
import XMonad.Actions.DynamicWorkspaceGroups -- (22d)
import XMonad.Actions.GroupNavigation
import XMonad.Actions.KeyRemap
import XMonad.Actions.OnScreen
import XMonad.Actions.PerWorkspaceKeys
import XMonad.Actions.ShowText
import XMonad.Actions.SpawnOn
import XMonad.Actions.TagWindows
import XMonad.Actions.UpdatePointer
import qualified XMonad.Actions.TreeSelect as TS
import qualified XMonad.Actions.Search as S
-- import XMonad.Actions.Search.Query
import XMonad.Actions.WindowBringer
import XMonad.Actions.WindowGo
import qualified XMonad.Actions.DynamicWorkspaceOrder as DO -- (22e)
import XMonad.Hooks.DynamicLog -- (1) for dzen status bar
import XMonad.Hooks.DynamicProperty
import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers -- (4) make lists of rules
import XMonad.Hooks.WorkspaceHistory (workspaceHistoryHook)
import XMonad.Hooks.ServerMode
import XMonad.Layout.ComboP
import XMonad.Layout.Reflect
import XMonad.Layout.Renamed
import XMonad.Layout.ResizableTile          -- Resizable Horizontal border
import XMonad.Layout.ShowWName
import XMonad.Layout.Accordion
import XMonad.Layout.Circle
import XMonad.Layout.LayoutCombinators
import XMonad.Layout.LayoutModifier
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.MultiColumns
import XMonad.Layout.Named -- (9) rename some layouts
import XMonad.Layout.PerWorkspace -- (10) use different layouts on different WSs
import XMonad.Layout.Reflect
import XMonad.Layout.Spacing
import XMonad.Layout.Simplest
import XMonad.Layout.SimpleFloat
import XMonad.Layout.SubLayouts
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.TwoPane
import XMonad.Layout.WindowNavigation -- (5) navigate windos directionally
import XMonad.Layout.WorkspaceDir
import XMonad.Layout.NoBorders
-- spacing between tiles
import XMonad.Prompt -- (23) general prompt stuff.
import XMonad.Prompt.Man -- (24) man page prompt
import XMonad.Prompt.AppendFile -- (25) append stuff to my NOTES file
import XMonad.Prompt.Ssh -- (26) ssh prompt
import XMonad.Prompt.Input -- (26) generic input prompt
import XMonad.Prompt.Workspace -- (27) prompt for a workspace
--import XMonad.Util.Dmenu
import qualified XMonad.Util.Dmenu as DM
import XMonad.Util.EZConfig -- (mkKeymap,additionalKeysP) -- (29) "M-C-x" style keybindings
import XMonad.Util.NamedActions -- (NamedAction(..), addDescrKeys', (^++^), subtitle, addName, showKm)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Paste
import XMonad.Util.Run(spawnPipe, hPutStr)
import XMonad.Util.SpawnOnce
import XMonad.Util.Ungrab
import XMonad.Util.XSelection (getSelection)
import Foreign.C.Types (CLong)

----------------------------------------------
-- main
----------------------------------------------

modalmap :: M.Map (KeyMask, KeySym) (X ()) -> X ()
modalmap s = submap $ M.map (\x -> x >> modalmap s) s
-- . saveActions 
main :: IO ()
main = xmonad
        --xmproc <- spawnPipe ("xmobar -x 0 $HOME/.config/xmobar/" ++ colorScheme ++ "-xmobarrc")
        --xmproc <- spawnPipe "xmobar /home/user/.xmonad/xmobar/xmobar.hs"
       $ ewmh -- =< xmobar myConfig
       $ myConfig
 

myConfig = def
           { layoutHook = myLayout
           , startupHook = myStartupHook
           , handleEventHook = dynamicPropertyChange "WM_NAME" myDynHook <+>
             myBorderEventHook <+>
             myServerModeEventHook <+>
             handleTimerEvent <+>
             serverModeEventHook <+>
             serverModeEventHookF "XMONAD_PRINT" (io . putStrLn)
              -- <+> handleEventHook def 
           -- docks <+>
           , manageHook = manageSpawn <+> myManageHook
           , focusedBorderColor = myFocusColor
           , normalBorderColor = myNormColor
                -- , logHook = workspaceHistoryHook <+>
           , logHook = workspaceHistoryHook <+> historyHook
                            -- myLogHook -- <+>
                            --dynamicLogWithPP xmobarPP 
                     -- { ppOutput = hPutStrLn xmproc
                     -- , ppTitle = xmobarColor "green" "" . shorten 50
                     -- , ppWsSep = " "
                     -- , ppSep = "  ||  "
                     -- } -- <+> workspaceHistoryHook <+> historyHook 
-- , logHook = workspaceHistoryHook <+> historyHook >> updatePointer (1, 1) (0, 0) <+> 
           , terminal = "alacritty"
           , modMask = mod4Mask
           , workspaces = TS.toWorkspaces myWorkspaces -- toWorkspaces (goes before myWorkspaces)
           , keys = myKeys
           } --`additionalKeys` addKeys 

--addKeys = [ ((0, xK_7), spawn "notify-send xterm")
 --         ] ++ buildKeyRemapBindings [tabKeyRemap,emptyKeyRemap]

--addKeys =  [ ("9", spawn "notify-send blah")
--           ] 

-- ++ buildKeyRemapBindings [tabKeyRemap,emptyKeyRemap]

----------------------------------------------
-- layout
-----------------------------------------------

-- myLayout = myTall ||| simpleFloat
myLayout = avoidStruts Full ||| Mirror halftiled ||| halftiled ||| thirdtiled ||| Mirror thirdtiled ||| iithirdtiled ||| swapthirdtiled
  where
     --             nmaster delta ratio
     halftiled   = Tall nmaster delta half
     thirdtiled  = Tall nmaster delta third
     swapthirdtiled  = Tall nmaster delta swapthird
     iithirdtiled  = Tall nmaster delta iithird

     nmaster = 1
     half   = 1/2
     third  = 1/3
     swapthird  = 1/5
     iithird  = 2/3
     delta   = 3/100

-- myTall =  avoidStruts $ windowNavigation $ addTabs shrinkText myTheme $ spacing 2 $
--   Full ||| term
--   where
--     rt      = ResizableTall 1 (3/100) (1/2) []
--     tall    = named "Tall" $ subLayout [0,1,2] (Simplest) $ rt
--     mtall   = named "Mirror" $ subLayout [0,1,2] (Simplest) $ Mirror rt
--     term_rt = ResizableTall 1 (50/100) (1/2) []
--     term    = named "term" $ reflectHoriz $ combineTwoP (term_rt) (tall) (Simplest) (ClassName "Qutebrowser")
-- fullscreenLayout = named "fullscreen" $ noBorders Full
-- 
-- myFall =  avoidStruts $ windowNavigation $ addTabs shrinkText myTheme $ spacing 2 $
--   Full ||| blah
--   where
--     bt    = ResizableTall 1 (3/100) (1/2) []
--     tall  = named "Tall" $ subLayout [0,1,2] (Simplest) $ bt
--     mtall = named "Mirror" $ subLayout [0,1,2] (Simplest) $ Mirror bt
--     blah_rt    = ResizableTall 1 (40/100) (1/2) []
--     blah  = named "Blah" $ reflectHoriz $ combineTwoP (blah_rt) (tall) (Simplest) (ClassName "Firefox")

  -- use window rule commands as query
addBorderQuery :: Query Bool
addBorderQuery = title =? "tabswitch"

addBorder :: Window -> X ()
addBorder ws = withDisplay $ \d -> mapM_ (\w -> io $ setWindowBorderWidth d w 10) [ws]

myBorderEventHook :: Event -> X All
myBorderEventHook (MapNotifyEvent {ev_window = window}) = do
    whenX (runQuery addBorderQuery window) (addBorder window)
    return $ All True

myBorderEventHook _ = return $ All True

----------------------------------------------
-- theme
----------------------------------------------
myNormColor :: String
myNormColor   = "#292d3e"  -- Border color of normal windows
myFocusColor :: String
myFocusColor  = "#bbc5ff"

--myTabConfig = def { inactiveBorderColor = "#708090"
--                  , activeBorderColor = "#5f9ea0"
--                  , activeColor = "#000000"
--                  , inactiveColor = "#333333"
--                  , inactiveTextColor = "#888888"
--                  , activeTextColor = "#87cefa"
--                  , fontName = "-xos4-terminus-*-*-*-*-12-*-*-*-*-*-*-*"
--                  }

active  = "#002b36"
base03  = "#002b36"
base02  = "#073642"
base01  = "#586e75"
base00  = "#657b83"
base0   = "#839496"
base1   = "#93a1a1"
base2   = "#eee8d5"
base3   = "#fdf6e3"
yellow  = "#b58900"
orange  = "#cb4b16"
red     = "#dc322f"
magenta = "#d33682"
violet  = "#6c71c4"
blue    = "#268bd2"
cyan    = "#2aa198"
green   = "#859900"

--myTheme = def
--    { activeColor =         "#123225"
--    , inactiveColor =       "#150252"
--    , urgentColor =         "#110000"
--    , activeBorderColor =   "#555222"
--    , inactiveBorderColor = "#555000"
--    , urgentBorderColor =   "#cc0550"
--    , activeTextColor =     "#aaaaaa"
--    , inactiveTextColor =   "#888888"
--    , urgentTextColor =     "#cc0000"
--    , fontName = "" ++ myFont ++ ""
--   , decoWidth = "29"
--    , decoHeight = "29"
--    }

--myTabTheme = def
--    { fontName              = myFont
--    , activeColor           = active
--    , inactiveColor         = base02
--    , activeBorderColor     = active
--    , inactiveBorderColor   = base02
--    , activeTextColor       = base03
--    , inactiveTextColor     = base00
--    }

--tabConfig = def {
--    activeBorderColor = "#7C7C7C",
--    activeTextColor = "#CEFFAC",
--    activeColor = "#000000",
--    inactiveBorderColor = "#7C7C7C",
--    inactiveTextColor = "#EEEEEE",
--    inactiveColor = "#000000"
--}

tsDefaultConfig :: TS.TSConfig a
tsDefaultConfig = TS.TSConfig { TS.ts_hidechildren = True
 		              , TS.ts_background   = 0xddEEEEEE
 			      , TS.ts_font         = "xft:Sans-26"
                              , TS.ts_node         = (0xff000000, 0xffdddddd)
                              , TS.ts_nodealt      = (0xff000000, 0xffdddddd)
                              , TS.ts_highlight    = (0xff000000, 0xff777777)
                              , TS.ts_extra        = 0xff000000
                              , TS.ts_node_width   = 300
                              , TS.ts_node_height  = 40
                              , TS.ts_originX      = 0
                              , TS.ts_originY      = 0
                              , TS.ts_indent       = 80
 			      , TS.ts_navigate 		 = myTreeNavigation
			      }


-- some nice colors for the prompt windows to match the dzen status bar.
myXPConfig = def                                    -- (23)
    { fgColor = "#a8a3f7"
    , bgColor = "#3f3c6d"
    , promptBorderWidth = 1
    , alwaysHighlight = True
    , height = 46
    , historySize = 256
    , font = myFont
    , position = Top
    , autoComplete = Nothing
    , showCompletionOnTab = False
    , defaultPrompter = id
    , sorter = const id
    , maxComplRows = Just 7
    , promptKeymap = defaultXPKeymap
    , completionKey = (0, xK_Tab)
    , changeModeKey = xK_grave
    , historyFilter = id
    , defaultText = []
    }

myLogHook :: X ()
myLogHook = fadeInactiveLogHook fadeAmount
    where fadeAmount = 1.0

-- myLogHook :: Handle -> X ()
-- myLogHook h = dynamicLogWithPP $ defaultPP
--     { ppCurrent           =   dzenColor "#ebac54" "#1B1D1E" . pad
--     , ppVisible           =   dzenColor "white" "#1B1D1E" . pad
--     , ppHidden            =   dzenColor "white" "#1B1D1E" . pad
--     , ppHiddenNoWindows   =   dzenColor "#7b7b7b" "#1B1D1E" . pad
--     , ppUrgent            =   dzenColor "#ff0000" "#1B1D1E" . pad
--     , ppWsSep             =   " "
--     , ppSep               =   "  |  "
--     , ppTitle             =   (" " ++) . dzenColor "white" "#1B1D1E" . dzenEscape
--     , ppOutput            =   hPutStrLn h
--     }


----------------------------------------------
-- aliases
----------------------------------------------

myTerm = "alacritty -e zsh -s "
myTermClass = "Alacritty"
myFont     = "xft:Source Code Pro:regular:pixelsize=35"
myTestFont = "-*-terminus-medium-*-*-*-*-160-*-*-*-*-*-*" 
myOnion = "~/mine/apps/tor-browser_en-US/Browser/start-tor-browser"

----------------------------------------------
-- startup
----------------------------------------------

myStartupHook = do
     spawn "emacs --daemon"
     spawn "xset s noblank"
     spawn "xset s 0 0"
     spawn "xset dpms 0 0 0"
     spawn "xset -dpms"
     spawn "xset -r 70"
     spawn "killall xbindkeys ; sleep 1 ; xbindkeys"
     spawn "xrandr --dpi 120 && xrdb -merge ~/.Xresources"
     spawn "bash -c \"pgrep -i dunst || dunst &\""
     spawn "bash -c \"pgrep -i urxvtd || urxvtd &\""
     spawn "xrandr --output eDP-1 --off --output DP-1 --off --output HDMI-1 --primary --mode 2200x1650 --pos 0x0 --rotate normal --output DP-2 --off"
     -- spawnOnce "nm-applet"
     -- spawnOnce "/home/user/.local/bin/kmonadre perix"
     -- spawnOnce "autorandr --load paperlike"
     spawn "hsetroot -solid White"
     setDefaultKeyRemap emptyKeyRemap [emptyKeyRemap, tabKeyRemap]

focusFollowsMouse = False

----------------------------------------------
-- scratchpads
----------------------------------------------
 
myScratchpads :: [NamedScratchpad]
myScratchpads = 
    [ NS "file" "alacritty -t File -e nnn -n /data/mine/books"
             (title =? "File")
             (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3))
    , NS "term" "tilix -t matchthis" -- -e tmux -uLmain attach -t1"
             (title =? "matchthis")
             (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3))
    ]
		where role = stringProperty "WM_WINDOW_ROLE"

-- I like to have these floating windows transparent
myNSManageHook :: NamedScratchpads -> ManageHook
myNSManageHook s =
    namedScratchpadManageHook s
    <+> composeOne
            [ title =? "File"
              -?> (ask >>= \w -> liftX (setOpacity w 1) >> idHook)
            , title =? "matchthis"
              -?> (ask >>= \w -> liftX (setOpacity w 1) >> idHook)
            ]

myManageHook = composeAll
    [ (className =? "Emacs"     <&&> title =? "emacs-capture"     --> (doRectFloat $ W.RationalRect 0.17 0.09 0.65 0.8))
    --, (className =? "tilix"     <&&> title =? "matchthis"         --> (doRectFloat $ W.RationalRect 0.17 0.09 0.65 0.8))
    , (className =? myTermClass <&&> title =? "tabswitch" --> (doRectFloat $ W.RationalRect 0.17 0.09 0.65 0.8))
    , (className =? myTermClass <&&> title =? "lfmenu" --> (doRectFloat $ W.RationalRect 0.17 0.09 0.65 0.8))
    , (className =? "unetbootin.elf" <&&> title =? "UNetbootin" --> (doRectFloat $ W.RationalRect 0.17 0.09 0.65 0.8))
    -- left top right bottom 
    , (className =? "Guake" --> doFloat)
    , (className =? "dmenu" --> doFloat)
    -- , (className =? "VirtualBox Machine" --> doF Just $ do spawn "xrandr --output HDMI-2 --scale 0.4x0.4")
    , (className =? "Zenity" --> (doRectFloat $ W.RationalRect 0.17 0.19 0.65 0.58))
    --, (className =? "URxvtF" --> (doRectFloat $ W.RationalRect 0.17 0.09 0.65 0.8))
    , (className =? "URxvt" --> doFloat)
    , (className =? "virt-manager" <&&> title =? "win7 on QEMU/KVM" --> viewShift "apps.libvirt")
    , (isRole =? "pop-up" --> doCenterFloat)
    , (isDialog           --> doCenterFloat)
    , (isSplash           --> doCenterFloat)
    ]
    where
      viewShift = doF . liftM2 (.) W.greedyView W.shift
      isRole              = stringProperty "WM_WINDOW_ROLE"
      isSplash            = isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_SPLASH"
      --tileBelow           = insertPosition Below Newer

  
myDynHook = composeAll

    --, (className =? "Tor Browser" <&&> title *!? "^.*Tor Browser.*" --> viewShift "web.onion")
    [ (className =? "VirtualBox Machine" <&&> title =? "arch [Running] - Oracle VM VirtualBox" --> viewShift "apps.virtualbox")
    , (className =? "Navigator" <&&> title =? "Extension: (Selenium IDE)*" --> (doRectFloat $ W.RationalRect 0.17 0.09 0.65 0.8))
    ]
    <+> namedScratchpadManageHook myScratchpads
    where
      viewShift = doF . liftM2 (.) W.greedyView W.shift
      --matchTag = (doF W.greedyView) --(addTag "blah")
    --, ("M-t t", do print [ 1 , 2 ] <- spawnPipe "notify-send")
    --, ("M-g g", withFocused $ windows . W.sink)

----------------------------------------------
-- workspaces
----------------------------------------------


--moveTo :: [String] -- ^ path, always starting from the top
--       -> TreeSelect a (Maybe a)
--moveTo i = moveWith (followPath tsn_name i . rootNode) >> redraw >> navigate . select

commands :: X [(String, X ())]
commands = workspaceCommands

defaultBG    = "#dbdbdb"
defaultFG    = "#000000"
hilightBG    = "#5e8eba"
hilightFG    = "#ffffff"

myDmenuFont     = "xft:Source Code Pro:regular:pixelsize=35"

dmenuArgs :: String -> [String]
dmenuArgs prompt =
    [ "-b"
    , "-fn" , myDmenuFont
    , "-nb" , defaultBG
    , "-nf" , defaultFG
    , "-sb" , hilightBG
    , "-sf" , hilightFG
    , "-p"  , prompt
    ]


----------------------------------------------
-- functions
----------------------------------------------

--(*!=) :: String -> String -> Bool
--q *!= x = isNothing $ matchRegex (mkRegex x) q

--(*!?) :: Functor f => f String -> String -> f Bool
--q *!? x = fmap (*!= x) q


data WindowPrompt = Goto | Bring | BringCopy
instance XPrompt WindowPrompt where
    showXPrompt Goto      = "Go to window: "
    showXPrompt Bring     = "Bring window: "
    showXPrompt BringCopy = "Bring a copy: "
    commandToComplete _ c = c
    nextCompletion      _ = getNextCompletion

windowPromptGoto, windowPromptBring, windowPromptBringCopy :: XPConfig -> X ()
windowPromptGoto  = doPrompt Goto
windowPromptBring = doPrompt Bring
windowPromptBringCopy = doPrompt BringCopy

-- | Pops open a prompt with window titles. Choose one, and you will be
-- taken to the corresponding workspace.
doPrompt :: WindowPrompt -> XPConfig -> X ()
doPrompt t c = do
  a <- case t of
         Goto  -> fmap gotoAction  windowMap
         Bring -> fmap bringAction windowMap
         BringCopy -> fmap bringCopyAction windowMap
  wm <- windowMap
  mkXPrompt t c (compList wm) a

    where
      winAction a m    = flip whenJust (windows . a) . flip M.lookup m
      gotoAction       = winAction W.focusWindow
      bringAction      = winAction bringWindow
      bringCopyAction  = winAction bringCopyWindow

      compList m s = return . filter (isInfixOf s) . map fst . M.toList $ m


-- | Brings a copy of the specified window into the current workspace.
bringCopyWindow :: Window -> WindowSet -> WindowSet
bringCopyWindow w ws = copyWindow w (W.currentTag ws) ws

killAllPrompt = inputPromptWithCompl myXPConfig {autoComplete = Nothing}
                "kill process" runningProcessesCompl ?+ killAllProc
killAllProc procName = spawn ("killall " ++ procName)
runningProcessesCompl str = runningProcesses >>= 
    (\procs -> return $ filter (\proc -> str `isPrefixOf` proc) procs)
runningProcesses = getDirectoryContents "/proc" >>= 
    (\dir -> return $ map (\pid -> "/proc/" ++ pid ++ "/comm") $ 
    filter (\dir -> all isDigit dir) $ dir) >>= 
    (\filenames -> sequence $ 
    map (\filename -> openFile filename ReadMode >>= 
    hGetContents) filenames) >>= 
    (\procs -> return $ sort $ nub $ 
    map (\proc -> init proc) procs)

onScr :: ScreenId -> (WorkspaceId -> WindowSet -> WindowSet) -> WorkspaceId -> X ()
onScr n f i = screenWorkspace n >>= \sn -> windows (f i . maybe id W.view sn)


newtype LastCmd = LastCmd { unCmd :: X () }

instance ExtensionClass LastCmd where
    initialValue = LastCmd (pure ())

repeatAction :: X ()
repeatAction = unCmd =<< XS.get

saveAction :: X () -> X ()
saveAction action = action >> XS.put (LastCmd action)
-- lucky that 'X' is not linear, huh :)

saveActions :: XConfig l -> XConfig l
saveActions conf = conf{ keys = Map.insert (mod4Mask, xK_3) repeatAction
                              . Map.map (& saveAction)
                              . keys conf
                       }

-- Not exposed.
type KeyBinding = ((KeyMask, KeySym), X ())

-- | Enters a mode in which given keybindings take effect; exit on unbound keys.
softInputMode :: [KeyBinding] -> X ()
softInputMode = inputMode (return ()) 0 xK_Escape

-- | Enters a mode in which /only/ given keybindings take effect; exit on escape.
hardInputMode :: [KeyBinding] -> X ()
hardInputMode bindings = self
  where self = inputMode self 0 xK_F10 bindings

-- | Enters a mode in which given keybindings take effect, and unmapped keys
--   perform def. Exit on (exitMask, exitKey).
inputMode :: X () -> KeyMask -> KeySym -> [KeyBinding] -> X ()
inputMode def exitMask exitKey bindings = self
  where self = submapDefault def . M.fromList
             $ map2 id (>> self) bindings ++ [((exitMask, exitKey), return ())]

-- Should be standard, right? Seems useful. Not exposed.
map2 :: (a -> c) -> (b -> d) -> [(a, b)] -> [(c, d)]
map2 f g l = zip (map (f . fst) l) (map (g . snd) l)

--navigateQuteTabs = hardInputMode      [
--
--      --  ((0, xK_k),      spawn "for i in $(xdotool search --pid $(wmctrl -lp | grep $(wmctrl -d | awk '/*/ {print $1}') | awk '/.*(linux|web|tube|politics)$/ {print $3}')); do xdotool key --window $i F10 && xdotool key --window $i Down; done && ~/.config/xmonad/xmonadctl qutetabs")
--
--      --, ((0, xK_i),      spawn "for i in $(xdotool search --pid $(wmctrl -lp | grep $(wmctrl -d | awk '/*/ {print $1}') | awk '/.*(linux|eb|tube|politics)$/ {print $3}')); do xdotool key --window $i F10 && xdotool key --window $i Up; done && ~/.config/xmonad/xmonadctl qutetabs")
--
--        ((0, xK_k), spawn "xdotool key Down")
--      , ((0, xK_i), spawn "xdotool key Up")
--      , ((0, xK_l), spawn "xdotool key Left")
--      , ((0, xK_j), spawn "xdotool key Right")
--
--
--      --, ((0, xK_space), sequence_ [ spawn "xdotool key F10 && xdotool key Return" , setKeyRemap emptyKeyRemap ])
--      , ((0, xK_space), spawn "xdotool key F10 && xdotool key Return")
--      --, ((0, xK_Escape), sequence_ [ spawn "xdotool key F10 && xdotool key Escape" , setKeyRemap emptyKeyRemap ])
--      , ((0, xK_Escape), spawn "xdotool key F10 && xdotool key Escape")
--
--      --, ((0, xK_space),  spawn "for i in $(xdotool search --pid $(wmctrl -lp | grep $(wmctrl -d | awk '/*/ {print $1}') | awk '/.*(linux|web|tube|politics)$/ {print $3}')); do xdotool key --window $i F10; xdotool key --window $i Return; done")
--
--      --, ((0, xK_Escape),  spawn "for i in $(xdotool search --pid $(wmctrl -lp | grep $(wmctrl -d | awk '/*/ {print $1}') | awk '/.*(linux|web|tube|politics)$/ {print $3}')); do xdotool key --window $i F10; xdotool key --window $i Escape; done")
--      ] 
--navigateQuteTabs = submap . M.fromList $
--      [ ((0, xK_k),      spawn "xinput key Down")
--      , ((0, xK_i),      spawn "xinput key Up")
--      , ((0, xK_space),  spawn "xinput key Return")
--      ]


--navigateQuteTabsInside = hardInputMode      [
--        ((0, xK_k), spawn "xdotool key F10 && xdotool key Down && ~/.config/xmonad/xmonadctl qutetabsinside")
--      , ((0, xK_i), spawn "xdotool key F10 && xdotool key Up && ~/.config/xmonad/xmonadctl qutetabsinside")
--      , ((0, xK_space), spawn "xdotool key F10 && xdotool key F10 && xdotool key Return")
--      , ((0, xK_Escape), spawn "xdotool key F10 && xdotool key F10 && xdotool key Escape")
--        ]
  
tabKeyRemap = KeymapTable [ ((0, xK_i), (0, xK_Up))
                            , ((0, xK_k), (0, xK_Down))
                            , ((0, xK_q), (0, xK_7))
                            --, ((0, xK_Escape), (mod4Mask, xK_Escape))
                            ]

navigateQuteTabs = submap . M.fromList $
      [ ((0, xK_q),      setKeyRemap emptyKeyRemap)
      , ((0, xK_w),      spawn "xdotool key w")
      , ((0, xK_e),      spawn "xdotool key e")
--      , ((0, xK_r),      spawn "xdotool key r")
--      , ((0, xK_t),      spawn "xdotool key t")
--      , ((0, xK_y),      spawn "xdotool key y")
--      , ((0, xK_u),      spawn "xdotool key u")
--      --, ((0, xK_i),      sequence_ [ spawn "xdotool key Up", spawn "~/.config/xmonad/xmonadctl qutetabmode" ])
--      , ((0, xK_o),      spawn "xdotool key o")
--      , ((0, xK_p),      spawn "xdotool key p")
--      , ((0, xK_a),      spawn "xdotool key a")
--      , ((0, xK_s),      spawn "xdotool key s")
--      , ((0, xK_d),      spawn "xdotool key d")
--      , ((0, xK_f),      spawn "xdotool key f")
--      , ((0, xK_g),      spawn "xdotool key g")
--      , ((0, xK_h),      spawn "xdotool key h")
        , ((0, xK_i),      sequence_ [ spawn "xdotool key Up", navigateQuteTabs ])
        , ((0, xK_k),      sequence_ [ spawn "xdotool key Down", navigateQuteTabs ])
--      , ((0, xK_j),      sequence_ [ spawn "xdotool key Left", spawn "~/.config/xmonad/xmonadctl qutetabmode" ])
--      , ((0, xK_k),      sequence_ [ spawn "xdotool key Down", spawn "~/.config/xmonad/xmonadctl qutetabmode" ])
--      , ((0, xK_l),      sequence_ [ spawn "xdotool key Right", spawn "~/.config/xmonad/xmonadctl qutetabmode" ])
--
--      , ((0, xK_z),      spawn "xdotool key z")
--      , ((0, xK_x),      spawn "xdotool key x")
--      , ((0, xK_c),      spawn "xdotool key c")
--      , ((0, xK_v),      spawn "xdotool key v")
--      , ((0, xK_b),      spawn "xdotool key b")
--      , ((0, xK_n),      spawn "xdotool key n")
--      , ((0, xK_m),      spawn "xdotool key m")
      , ((0, xK_space),  setKeyRemap emptyKeyRemap)
      ]

--navigateQuteTabs = submap . M.fromList $
--      , ((0, xK_space),  spawn "xdotool key return")
--      ]
--setKeyRemap emptyKeyRemap

prepareKeys = submap . M.fromList $
      [ ((0, xK_q),      spawn "notify-send blah")
      , ((0, xK_w),      spawn "notify-send blah")
      , ((0, xK_e),      spawn "notify-send blah")
      , ((0, xK_r),      spawn "notify-send blah")
      , ((0, xK_t),      spawn "notify-send blah")
      , ((0, xK_y),      spawn "notify-send blah")
      , ((0, xK_u),      spawn "notify-send blah")
      , ((0, xK_i),      spawn "notify-send blah")
      , ((0, xK_o),      spawn "notify-send blah")
      , ((0, xK_p),      spawn "notify-send blah")
      , ((0, xK_a),      spawn "notify-send blah")
      , ((0, xK_s),      spawn "notify-send blah")
      , ((0, xK_d),      spawn "notify-send blah")
      , ((0, xK_f),      spawn "notify-send blah")
      , ((0, xK_g),      spawn "notify-send blah")
      , ((0, xK_h),      spawn "notify-send blah")
      , ((0, xK_j),      spawn "notify-send blah")
      , ((0, xK_k),      spawn "notify-send blah")
      , ((0, xK_l),      spawn "notify-send blah")
      , ((0, xK_z),      spawn "notify-send blah")
      , ((0, xK_x),      spawn "notify-send blah")
      , ((0, xK_c),      spawn "notify-send blah")
      , ((0, xK_v),      spawn "notify-send blah")
      , ((0, xK_b),      spawn "notify-send blah")
      , ((0, xK_n),      spawn "notify-send blah")
      , ((0, xK_m),      spawn "notify-send blah")
      , ((0, xK_space),  spawn "notify-send blah")
      ]


demonstrationQute = submap . M.fromList $
      [ ((0, xK_c),      spawn "notify-send \"Cloning tabs. (key = c)\"")
      , ((0, xK_d),      spawn "notify-send \"Deleting all tabs below or above. (Key = D)\"")
      , ((0, xK_m),      spawn "notify-send \"Moving between tabs. (key = i/k)\"")
      , ((0, xK_n),      spawn "notify-send \"Creating new tabs. (key = n)\"")
      , ((0, xK_p),      spawn "notify-send \"Pinning tabs. (key = p)\"")
      , ((0, xK_s),      spawn "notify-send \"Switching between title and url formats. (key = s)\"")
      , ((0, xK_u),      spawn "notify-send \"Undoing/restoring tabs. (key = U)\"")
      , ((0, xK_x),      spawn "notify-send \"Closing tabs. (key x/X)\"")
      ]

  -- External commands
myCommands :: [(String, X ())]
myCommands =
        [ ("decrease-master-size"      , sendMessage Shrink)
        , ("turnscrollon"              , prepareKeys)
        --, ("flashsometext"             , flashText defaultSTConfig 5 "some message here" >> nextWS )
        --, ("preparekeys"               , spawn "~/.local/bin/startinput")
        , ("qutetabs"                  , sequence_ [ setKeyRemap tabKeyRemap , navigateQuteTabs ] )
        , ("updownremap"               , setKeyRemap tabKeyRemap)
        , ("qutetabmode"               , navigateQuteTabs)
        --, ("qutetabsinside"            , navigateQuteTabsInside)
        , ("testthing"                 , spawn "notify-send test")
        , ("shutdown"                  , spawn "shutdown now")
        , ("startalterm"               , spawn myTerm)
        , ("showqute"                  , sequence_ [ spawn "~/.local/bin/controlscreenkey run 2", spawn "~/.local/bin/switchdunst center", demonstrationQute, spawn "sleep 2 && ~/.local/bin/switchdunst default" ])
        ]

myServerModeEventHook = serverModeEventHookCmd' $ return myCommands'
myCommands' = ("list-commands", listMyServerCmds) : myCommands -- ++ wscs ++ sccs -- ++ spcs
--    where
--        wscs = [((m ++ s), windows $f s) | s <- myWorkspaces
--               , (f, m) <- [(W.view, "focus-workspace-"), (Wshift, "send-to-workspace-")] ]
--
--        sccs = [((m ++ show sc), screenWorkspace (fromIntegral sc) >>= flip whenJust (windows . f))
--               | sc <- [0..myMaxScreenCount], (f, m) <- [(W.view, "focus-screen-"), (W.shift, "send-to-screen-")]]

--        spcs = [("toggle-" ++ sp, namedScratchpadAction myScratchpads sp)
--               | sp <- (flip map) (myScratchpads) (\(NS x _ _ _) -> x) ]

listMyServerCmds :: X ()
listMyServerCmds = spawn ("echo '" ++ asmc ++ "' | xmessage -file -")
    where asmc = concat $ "Available commands:" : map (\(x, _)-> "    " ++ x) myCommands'



----------------------------------------------
-- keybinds
----------------------------------------------

toggleScroll :: X ()
toggleScroll = spawn ("~/.local/bin/mux scroll")

--showKeybindings :: [((KeyMask, KeySym), NamedAction)] -> NamedAction
--showKeybindings x = io $ do
--  h <- spawnPipe "zenity --text-info --font=terminus"
--  hPutStr h (unlines $ showKm x)
--  hClose h
--  return ()

--myAdditionalKeys c = (subtitle "Custom Keys":) $ mkNamedKeymap c $
--  myDesktopKeys 
--myKeys c = mkKeymap c $

--myKeys conf = let
--    subKeys str ks        = subtitle str : mkNamedKeymap conf ks
--    screenKeys            = ["w","v","z"]
--    directionKeys         = ["j","k","h","l"]
--    directions            = [ D,  U,  L,  R ]
--    --screenAction f        = screenWorkspace >=> flip whenJust (windows . f)
--    zipMod nm ks as m f = zipWith (\k d -> (m ++ k, addName nm $ f d)) ks as
--    zipMod' nm ks as m f b = zipWith (\k d -> (m ++ k, addName nm $ f d b)) ks as
--    in

toggleWorkspaceEscape = sequence_ [ toggleWS' ["NSP"], spawn "xdotool key Escape" ]

treeMenuEscape = sequence_ [ TS.treeselectWorkspace tsDefaultConfig myWorkspaces W.greedyView, spawn "xdotool key Escape" ]

treeMenuTopic = sequence_ [ TS.treeselectWorkspace tsDefaultConfig myWorkspaces W.greedyView, spawn "~/.local/bin/topic" ]

notifyAddOn = "fuck"

selectLimit = do
  result <- DM.menuArgs "wsdmenu" ["-i"] ["2", "3", "4"]
  return result
  --setLimit $ read result

myKeys c = mkKeymap c $
  myWorkspaceKeys ++ myWindowKeys ++ myProgramKeys ++ mySystemCommandKeys ++ myScreenCommandKeys ++ myMouseKeys


myWorkspaceKeys =
    [ ("M-w", TS.treeselectWorkspace tsDefaultConfig myWorkspaces W.greedyView) 
    --[ ("M-w", treeMenuEscape) 

    , ("<F1>", spawn "~/.local/bin/startinput rollermouse")
    , ("<F2>", spawn "~/.local/bin/startinput trappermouse")
    , ("M-m", toggleWS' ["NSP"])
    ]

myWindowKeys =
    [ ("M-s k", spawn "~/.local/bin/mux kill 2>&1 >/tmp/muxtest")
    , ("M-s s k", kill)
    , ("M-s s d", spawn "xrandr --output HDMI-2 --scale 1x1; xrandr --output HDMI-1 --scale 1x1")
    , ("M-s s l", spawn "xrandr --output HDMI-2 --scale 0.45x0.45; xrandr --output HDMI-1 --scale 0.45x0.45")
    , ("M-j", sequence_ [ windows W.focusDown, modalmap . M.fromList $
      [ ((0, xK_j), windows W.focusDown)
      , ((0, xK_l), windows W.focusUp)
      , ((0, xK_m), toggleWorkspaceEscape)
      , ((0, xK_w), treeMenuEscape) 
      , ((mod4Mask, xK_j), windows W.focusDown)
      , ((mod4Mask, xK_l), windows W.focusUp)
      , ((mod4Mask, xK_m), toggleWorkspaceEscape)
      , ((mod4Mask, xK_w), treeMenuEscape) 
      ]])
    , ("M-l", sequence_ [ windows W.focusUp, modalmap . M.fromList $
      [ ((0, xK_j), windows W.focusDown)
      , ((0, xK_l), windows W.focusUp)
      , ((0, xK_m), toggleWorkspaceEscape)
      , ((0, xK_w), treeMenuEscape)
      , ((mod4Mask, xK_j), windows W.focusDown)
      , ((mod4Mask, xK_l), windows W.focusUp)
      , ((mod4Mask, xK_m), toggleWorkspaceEscape)
      , ((mod4Mask, xK_w), treeMenuEscape) 
      ]])

    , ("M-s y", windowPromptBringCopy myXPConfig)
    -- , ("M-s b", windowPromptBring myXPConfig)
    , ("M-s g", windowPromptGoto myXPConfig)
    , ("M-s m", WindowMenu.windowMenu)
    , ("M-s .", shiftNextScreen)
    , ("M-s ,", shiftPrevScreen)
    ]

myProgramKeys =
    [ ("M-s o e", spawn myTerm) -- terminal
    , ("M-s o i", spawn "dmenu_run -l 30 -fn xft:terminus:style=medium:pixelsize=32 -nb \"#FFFFFF\" -nf \"#000000\"")
    , ("M-x", spawn "tmux switch-client -T table1") 
    , ("M-v", sequence_ [ spawn "~/.local/bin/volumelevel 0db-", modalmap . M.fromList $
      [ ((0, xK_i), spawn "~/.local/bin/volumelevel 1dB+ unmute")
      , ((0, xK_k), spawn "~/.local/bin/volumelevel 1db- unmute")
      , ((0, xK_m), spawn "notify-send mute/unmute && pactl set-sink-mute 0 toggle")

      ]])
    , ("M-o", spawn "~/.local/bin/dmenuwsb")
    , ("M-b", spawn "~/.local/bin/dmenuwsb books")
    , ("M-r r", spawn "~/.local/bin/controlscreenkey toggle 2")
    , ("M-r g", spawn "~/.local/bin/recordgif")
    , ("M-r s", spawn "~/.local/bin/recordgif --stop")
    , ("M-h", spawn "~/.local/bin/dmenuwsb parent")
    , ("M-s o o", spawn "~/.local/bin/topic")
    ]

mySystemCommandKeys =
    [ ("M-s q y", io exitSuccess)
    , ("M-s t t", spawn "~/.local/bin/test 2>&1 >/tmp/qutetest | notify-pipe")
    , ("M-s t n", spawn ("notify-send " ++ notifyAddOn))
    , ("M-s b", spawn "~/.local/bin/findmulti")
    --, ("C-S-0", spawn "notify-send blaaa")
    --, ("M-s t", spawn "ps | grep -v grep | head -n 1 | awk '$1=\" \ {print $0}' | notify-pipe")
    --, ("M-s t", spawn "if [[ $(pstree -p $(xdotool getactivewindow getwindowpid) | grep qutebrowser) != \"\" ]]; then $(ps -eo pid,args | grep -v grep | grep \"$(pstree -p $(xdotool getactivewindow getwindowpid) | grep qutebrowser | head -n 1 | sed -rn 's/^.*qutebrowser.([0-9]*).*/\1/p')\" | awk '$1=$2=\" \"{print $0}') :session-save :quit\"; fi

-- $(pstree -p $(xdotool getactivewindow getwindowpid) | grep qutebrowser | head -n 1)

-- getActiveWindow=$(pstree -p $(xdotool getactivewindow getwindowpid); qutename=$(echo $getActiveWindow | grep qutebrowser | head -n 1); 


    , ("M-s w", spawn "python /data/mine/python-scripts/wifi_switch.py --verbose --capture=no")
    , ("<F3>", sequence_ [ spawn "killall kmonad", spawn "/home/user/.local/bin/disablemouse" , spawn "systemctl suspend" ])
    , ("M-s r", spawn "~/.local/bin/xmocompile")
    , ("M-s n", namedScratchpadAction myScratchpads "term")
    , ("M-s f", namedScratchpadAction myScratchpads "file")
    --, ("8", setKeyRemap tabKeyRemap)
    --, ("9", setKeyRemap emptyKeyRemap)
    , ("S-<F4>", setKeyRemap emptyKeyRemap)
    --, ("1", setKeyRemap emptyKeyRemap)
    ]

myScreenCommandKeys =
    [ ("M-s l l", sendMessage NextLayout) 
    , ("M-1", spawn "autorandr --load 2einkbed")
    , ("M-2", spawn "autorandr --load paperbedflipped")
    , ("M-3", spawn "autorandr --load paperlike-dp")
    ] 

myMouseKeys =
    [ ("M-8", spawn "xinput set-prop 'Contour Design RollerMouse PRO2 Mouse' 'libinput Scroll Method Enabled' 0, 0, 0")
    , ("M-5", spawn "~/.local/bin/contour toggleHorizontal")
    , ("C-<F3>", spawn "~/.local/bin/mux scroll")
    ]
