{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix # Import the generated hardware config
  ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Time zone
  time.timeZone = "America/New_York";

  # Internationalization
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland;
  };

  # Enable a display manager (GDM) to start Hyprland
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;

  # Basic system packages
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    firefox
  ];


  # Enable OpenGL for Wayland
  hardware.opengl.enable = true;

  # User account
  users.users.jkpth = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    password = "password"; # Change this, jkpth!
  };

  # System state version
  system.stateVersion = "24.11";
}