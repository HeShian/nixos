{
  # Dux Greeter：替换原来的 noctalia-greeter。
  # greetd + dms-greeter（以 niri 作为登录界面合成器）。
  # configHome 会把用户的 ~/.config/dms/settings.json、~/.local/state/dms/session.json
  # 以及壁纸复制到 /var/lib/dms-greeter，让登录界面与桌面外观一致。
  den.aspects.dux-greeter = { host, ... }: {
    nixos.services.displayManager.dux-greeter = {
      enable = true;
      compositor.name = "niri";
      configHome = "/home/${host.defaultUser}";

      # 登录界面专用的最小 niri 配置：替换 niri 默认配置，
      # 避免默认配置在登录界面启动时弹出 “Important Hotkeys” 教程 / 尝试启动 waybar。
      compositor.customConfig = ''
        hotkey-overlay {
            skip-at-startup
        }

        prefer-no-csd

        layout {
            gaps 0
        }

        cursor {
            xcursor-theme "Bibata-Modern-Ice"
            xcursor-size 24
            hide-after-inactive-ms 0
        }

        // 与桌面一致的缩放；不存在的输出会被 niri 忽略
        output "eDP-1" {
            scale 1.25
        }

        environment {
            QS_ICON_THEME "Papirus-Dark"
        }
      '';
    };
  };
}
