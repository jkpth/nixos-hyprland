NixOS Hyprland Configuration
This repository contains a NixOS configuration with the Hyprland Wayland compositor, managed using Nix flakes and Home-manager.
Features

NixOS system configuration with Hyprland
Home-manager for user settings (dotfiles)
Basic Hyprland setup with Waybar, Kitty, and Rofi
Reproducible builds via flakes

Prerequisites

NixOS with flakes enabled
Git installed
Basic knowledge of Nix and Hyprland

Setup

Clone the repository:git clone https://github.com/jkpth/nixos-hyprland.git
cd nixos-hyprland


Ensure flakes are enabled in /etc/nixos/configuration.nix:nix.settings.experimental-features = [ "nix-command" "flakes" ];


Copy or symlink files to /etc/nixos:sudo cp -r . /etc/nixos/nixos-hyprland
sudo ln -s /etc/nixos/nixos-hyprland/flake.nix /etc/nixos/flake.nix


Rebuild the system:sudo nixos-rebuild switch --flake /etc/nixos#nixos


Log in as user with password password (change the password in configuration.nix).

Customization

Edit configuration.nix for system settings.
Modify home.nix for user packages and dotfiles.
Adjust hyprland.conf for Hyprland keybindings and styling.

License
MIT
