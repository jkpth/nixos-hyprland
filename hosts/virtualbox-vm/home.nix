{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;

  home.username = "jkpth";
  home.homeDirectory = "/home/jkpth";

  programs.zsh.enable = true;
  programs.git.enable = true;
  programs.neovim.enable = true;
  programs.bash.enable = true;

  home.stateVersion = "24.05";
}
