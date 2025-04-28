{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # System version
  system.stateVersion = "24.05";

  # Allow unfree packages (needed for Spotify)
  nixpkgs.config.allowUnfree = true;

  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos-vm";
  networking.networkmanager.enable = true;

  # Time zone and locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # User configuration
  users.users.jkpth = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "input" ];
    shell = pkgs.zsh;
  };

  # Enable Zsh
  programs.zsh.enable = true;

  # Basic system packages
  environment.systemPackages = with pkgs; [
    git
    neovim
    wget
    curl
    firefox
    
    # Hyprland essentials
    hyprpaper
    waybar
    wofi
    mako
    grim
    slurp
    wl-clipboard
    alacritty
    libnotify
    
    # System utilities
    pavucontrol
    brightnessctl
    xarchiver
    polkit_gnome
  ];

  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Display manager
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # XDG Desktop portal for Wayland
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Environment variables for Wayland
  environment.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";
    # For Electron-based applications
    NIXOS_OZONE_WL = "1";
    # For Virtualbox
    WLR_NO_HARDWARE_CURSORS = "1";
    # XDG standards
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    liberation_ttf
    font-awesome
    jetbrains-mono
  ];

  # Audio
  sound.enable = false; # Disable ALSA sound for pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable D-Bus
  services.dbus.enable = true;
  
  # Enable Polkit for privilege elevation
  security.polkit.enable = true;
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
