# NixOS Hyprland Setup

This directory contains the NixOS configuration for a clean Hyprland setup in a VirtualBox VM.

## Post-Installation Steps

After rebuilding your system with `sudo nixos-rebuild switch --flake ~/nixos-config#virtualbox-vm`, you'll need to:

1. **Set up a wallpaper**:
   ```bash
   # Download a default wallpaper (nature landscape)
   curl -L "https://source.unsplash.com/random/1920x1080/?landscape,nature" -o ~/.wallpaper.jpg
   ```

2. **Log out and log back in** to ensure all changes take effect.

## Usage

### Key Bindings

- **Super + Enter** - Open terminal (Alacritty)
- **Super + D** - Open application launcher (Wofi)
- **Super + B** - Open Firefox
- **Super + Q** - Close active window
- **Super + M** - Exit Hyprland
- **Super + F** - Fullscreen
- **Super + Space** - Toggle floating
- **Super + h/j/k/l** - Move focus (left, down, up, right)
- **Super + 1-0** - Switch to workspace 1-10
- **Super + Shift + 1-0** - Move window to workspace 1-10
- **Super + mouse drag** - Move/resize windows
- **Print** - Take screenshot (selected area)

## Customization

You can further customize this setup by editing:

- **System configuration**: `configuration.nix`
- **User configuration**: `home.nix`

After making changes, rebuild with:

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#virtualbox-vm
``` 