{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "nodev" ]; # safe in VM

  users.users.jkpth = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    git
    neovim
    wget
    zsh
    firefox
    mako
    grim
    slurp
    wl-clipboard
    alacritty
    wofi
    waybar
  ];

  services.openssh.enable = true;

  system.stateVersion = "24.05";
  # Enable Wayland
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true; #lightweight DM
  services.displayManager.defaultSession = "hyprland";

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };


  # Enable Hyprland
  programs.hyprland.enable = true;

  # Set environment variables needed for Wayland apps
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Makes electron apps like VSCode work
    WLR_NO_HARDWARE_CURSORS = "1"; # Fix cursor glitches sometimes
  };

  # Basic apps
  services.dbus.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    liberation_ttf
  ];

  # Sound 
  sound.enable = true;
  hardware.pulseaudio.enable = true;



}
