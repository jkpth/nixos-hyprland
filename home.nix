{ config, pkgs, ... }:

{
  home.username = "jkpth";
  home.homeDirectory = "/home/jkpth";

  # Home-manager state version
  home.stateVersion = "24.11";

  # Hyprland config
  home.file.".config/hypr/hyprland.conf".source = ./hyprland.conf;

  # Basic user packages
  home.packages = with pkgs; [
    kitty
    waybar
    rofi-wayland
    swww
  ];

  # Enable Home-manager
  programs.home-manager.enable = true;
}