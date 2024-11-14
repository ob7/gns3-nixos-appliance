{ config
, pkgs
, ... }:
{
  users.motd = "GNS3-NixOS-Desktop";

  networking.usePredictableInterfaceNames = false;
  environment.systemPackages = with pkgs; [
    qutebrowser
    firefox
    alacritty
    tmux
    vim
  ];

  imports = [
    ./base.nix
  ];

  networking.firewall.enable = false;

  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.desktopManager.xfce.noDesktop = true;
  services.xserver.windowManager.xmonad.enable = true;
	services.xserver.windowManager.xmonad.enableContribAndExtras = true;

	services.displayManager.autoLogin = {
		user = "liveuser";
		enable = true;
	};

	services.xserver.displayManager.sessionCommands = ''
		xfconf-query -c displays -p /Default/Display0/Active -n -t bool -s false # Command to disable XFCE's automatic display rearrangement
		xfconf-query -c xfce4-session -p /startup/xfce4-settings-helper -n -t bool -s false
    xset -dpms & 
    xset s off &
    xset s noblank &
		xmonad --replace &
	'';

  services.xserver.windowManager.xmonad.config = ''
    import XMonad
    import XMonad.Util.EZConfig(additionalKeys)
    import XMonad.Util.SpawnOnce
    import XMonad.Actions.SpawnOn
    import XMonad.ManageHook

    main = xmonad $ def
      { terminal    = "alacritty"  -- Set xterm as the default terminal
      , modMask     = mod1Mask -- Use the alt key as the modifier
      , startupHook = myStartupHook
      , manageHook = myManageHook <+> manageHook def
      , workspaces  = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
      }

    myStartupHook = do
      spawnOn "1" "qutebrowser"                 -- Start Firefox on workspace 1
      spawnOn "2" "alacritty"               -- Start Alacritty on workspace 2

    myManageHook = composeAll
      [ className =? "Firefox" --> doShift "1"    -- Shift Firefox to workspace 1
      , className =? "Alacritty" --> doShift "2"  -- Shift Alacritty to workspace 2
      ]
  '';

  users.users.liveuser = {
    isNormalUser = true;
    home = "/home/liveuser";
    description = "Live User";
    extraGroups = [ "wheel" ];
    shell = pkgs.bashInteractive;
    initialPassword = "toor";
  };
}
