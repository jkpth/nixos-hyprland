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
  ];

  services.openssh.enable = true;

  system.stateVersion = "24.05";
}
