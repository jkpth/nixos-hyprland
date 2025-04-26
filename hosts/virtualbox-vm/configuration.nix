{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "virtualbox-vm";

  environment.systemPackages = with pkgs; [
    git
    neovim
    wget
    zsh
    firefox
  ];

  services.openssh.enable = true;
  users.users.blim = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # sudo access
    shell = pkgs.zsh;
  };

  system.stateVersion = "24.05";
}
