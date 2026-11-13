{
  # niri 图形会话及音频支持。
  den.aspects.niri.nixos.imports = [
  # 合成器、XWayland、会话变量与终端
  ({ pkgs, appearance, ... }: {
        programs.niri.enable = true;

        # nixpkgs 的 niri 模块默认关闭 wayland-session 里的 XWayland。
        # niri 按需启动 xwayland-satellite，并为 X11 客户端设置 DISPLAY。
        programs.xwayland.enable = true;
        environment.systemPackages = [ pkgs.xwayland-satellite ];

        environment.sessionVariables = {
          NIXOS_OZONE_WL = "1";
          MOZ_ENABLE_WAYLAND = "1";
          EDITOR = "nvim";
          TERMINAL = "kitty";
          # niri 也会按 cursor{} 给子进程设置；这里保证 DMS 服务等非 niri 子进程
          # 也拿到同一个光标主题。值来自 modules/_lib/appearance.nix（ADR-0006）。
          XCURSOR_THEME = appearance.cursor.theme;
          XCURSOR_SIZE = toString appearance.cursor.size;
        };

        # xdg-terminal-exec：让 portal / 文件管理器里的“在终端打开”使用 kitty
        xdg.terminal-exec = {
          enable = true;
          settings.default = [ "kitty.desktop" ];
        };
      })

  # PipeWire 与桌面音频
  ({
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };
      security.rtkit.enable = true;
      xdg.sounds.enable = true;
    })
];
}
