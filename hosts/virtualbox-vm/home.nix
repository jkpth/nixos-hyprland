{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;

  home.username = "jkpth";
  home.homeDirectory = "/home/jkpth";

  home.packages = with pkgs; [
    # Dev tools
    ripgrep
    fd
    fzf
    jq
    
    # GUI applications
    spotify
    vlc
    
    # Utilities
    htop
    neofetch
    
    # Theming
    papirus-icon-theme
    gnome.adwaita-icon-theme
  ];

  # Programs and configurations
  programs = {
    bash = {
      enable = true;
      shellAliases = {
        ll = "ls -la";
        update = "sudo nixos-rebuild switch --flake ~/nixos-config#virtualbox-vm";
      };
    };
    
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      shellAliases = {
        ll = "ls -la";
        update = "sudo nixos-rebuild switch --flake ~/nixos-config#virtualbox-vm";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "sudo" ];
        theme = "robbyrussell";
      };
    };
    
    git = {
      enable = true;
      userName = "jkpth";
      userEmail = "your-email@example.com"; # Change this to your email
    };
    
    alacritty = {
      enable = true;
      settings = {
        font = {
          normal.family = "JetBrains Mono";
          size = 11;
        };
        colors = {
          primary = {
            background = "#282a36";
            foreground = "#f8f8f2";
          };
        };
      };
    };
  };

  # Wayland-specific configurations
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    extraConfig = ''
      # Monitor configuration
      monitor=,preferred,auto,1

      # Autostart applications
      exec-once = hyprpaper
      exec-once = waybar
      exec-once = mako

      # Environment variables
      env = XCURSOR_SIZE,24

      # Input configuration
      input {
        kb_layout = us
        follow_mouse = 1
        
        touchpad {
          natural_scroll = true
          tap-to-click = true
        }
        
        sensitivity = 0
      }

      # General configuration
      general {
        gaps_in = 5
        gaps_out = 10
        border_size = 2
        col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
        col.inactive_border = rgba(595959aa)
        layout = dwindle
      }

      # Decoration configuration
      decoration {
        rounding = 10
        
        blur {
          enabled = true
          size = 8
          passes = 3
          new_optimizations = true
        }
        
        drop_shadow = true
        shadow_range = 20
        shadow_render_power = 3
        col.shadow = rgba(1a1a1aee)
      }

      # Animation configuration
      animations {
        enabled = true
        
        bezier = myBezier, 0.05, 0.9, 0.1, 1.05
        
        animation = windows, 1, 7, myBezier
        animation = windowsOut, 1, 7, default, popin 80%
        animation = border, 1, 10, default
        animation = fade, 1, 7, default
        animation = workspaces, 1, 6, default
      }

      # Layout configuration
      dwindle {
        pseudotile = true
        preserve_split = true
      }

      # Window rules
      windowrulev2 = opacity 0.8 0.8,class:^(Alacritty)$

      # Key bindings
      $mainMod = SUPER

      # Application shortcuts
      bind = $mainMod, RETURN, exec, alacritty
      bind = $mainMod, D, exec, wofi --show drun
      bind = $mainMod, B, exec, firefox
      
      # Window management
      bind = $mainMod, Q, killactive
      bind = $mainMod, M, exit
      bind = $mainMod, F, fullscreen
      bind = $mainMod, Space, togglefloating
      
      # Move focus
      bind = $mainMod, h, movefocus, l
      bind = $mainMod, l, movefocus, r
      bind = $mainMod, k, movefocus, u
      bind = $mainMod, j, movefocus, d
      
      # Switch workspaces
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10
      
      # Move active window to workspace
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10
      
      # Mouse bindings
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow
      
      # Screenshot
      bind = , Print, exec, grim -g "$(slurp)" - | wl-copy
    '';
  };

  # Configure Waybar
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = ''
      * {
        border: none;
        font-family: JetBrains Mono, Font Awesome;
        font-size: 13px;
      }
      
      window#waybar {
        background-color: rgba(40, 42, 54, 0.9);
        color: #f8f8f2;
        transition-property: background-color;
        transition-duration: .5s;
      }
      
      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: #f8f8f2;
      }
      
      #workspaces button:hover {
        background: rgba(68, 71, 90, 0.5);
        box-shadow: inherit;
      }
      
      #workspaces button.active {
        background-color: #44475a;
        color: #f1fa8c;
      }
      
      #clock, #battery, #cpu, #memory, #network, #pulseaudio, #temperature {
        padding: 0 10px;
        margin: 0 4px;
      }
    '';
    settings = [{
      layer = "top";
      position = "top";
      height = 30;
      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ "hyprland/window" ];
      modules-right = [ "pulseaudio" "network" "cpu" "memory" "battery" "clock" ];
      
      "hyprland/workspaces" = {
        format = "{name}";
        on-click = "activate";
      };
      
      "clock" = {
        format = "{:%H:%M}";
        format-alt = "{:%Y-%m-%d %H:%M:%S}";
        tooltip-format = "{:%Y-%m-%d | %H:%M:%S}";
        interval = 1;
      };
      
      "cpu" = {
        format = "CPU: {usage}%";
        interval = 1;
      };
      
      "memory" = {
        format = "MEM: {}%";
        interval = 1;
      };
      
      "network" = {
        format-wifi = "W: {signalStrength}%";
        format-ethernet = "E: {ipaddr}";
        format-disconnected = "Disconnected";
        interval = 1;
      };
      
      "pulseaudio" = {
        format = "VOL: {volume}%";
        on-click = "pavucontrol";
      };
    }];
  };

  # Configure notifications with Mako
  services.mako = {
    enable = true;
    defaultTimeout = 5000;
    backgroundColor = "#282a36";
    textColor = "#f8f8f2";
    borderColor = "#6272a4";
    borderRadius = 10;
    borderSize = 2;
    margin = "10";
    padding = "15";
    font = "JetBrains Mono 11";
  };

  # Configure wallpaper with Hyprpaper
  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = ~/.wallpaper.jpg
    wallpaper = ,~/.wallpaper.jpg
  '';

  # State version
  home.stateVersion = "24.05";
}
