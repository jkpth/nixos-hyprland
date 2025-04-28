{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;

  home.username = "jkpth";
  home.homeDirectory = "/home/jkpth";

  imports = [
    ../../modules/home/hyprland.nix
  ];

  home.stateVersion = "24.05";
}
