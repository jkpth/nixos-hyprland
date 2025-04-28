  { config, pkgs, ... }:

  {
    home.file.".config/hypr/hyprland.conf".text = ''
      monitor=,preferred,auto,1


      bind=SUPER, RETURN, exec, alacritty
      bind=SUPER, D, exec, wofi --show drun
      bind=SUPER, Q, killactive
      bind=SUPER, R, reload


      exec-once = hyprpaper
      exec-once = waybar

      input {
        kb_layout = us
        follow_mouse = 1
        touchpad {
          natural_scroll = true
        }
      }

      decoration {
        rounding = 10
        blur {
          enabled = true
	  size = 8
	  passes = 3
        }
        drop_shadow = true
        shadow_range = 20
        shadow_render_power = 3
      }
    '';
  }
