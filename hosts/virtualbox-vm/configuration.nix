{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  system.stateVersion = "24.05";

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
    firefox
    hyprpaper
    waybar
    wofi
    mako
    grim
    slurp
    wl-clipboard
    alacritty
  ];

  # Enable Hyprland and lightweight login
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  programs.hyprland.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    liberation_ttf
  ];

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  services.dbus.enable = true;
}
