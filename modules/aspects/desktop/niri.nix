{
  # niri 会话基座。
  # nixpkgs 的 programs.niri 已负责：
  #   - niri 包 / wayland-session / XDG autostart
  #   - displayManager.sessionPackages 与默认会话 "niri"
  #   - xdg.portal.config.niri（gnome + gtk）、gnome-keyring、dconf、polkit
  # 这里只补 XWayland、会话环境变量和终端规范。
  den.aspects.niri = {
    nixos = { pkgs, ... }: {
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
        # 也拿到同一个光标主题。
        XCURSOR_THEME = "Bibata-Modern-Ice";
        XCURSOR_SIZE = "24";
      };

      # xdg-terminal-exec：让 portal / 文件管理器里的“在终端打开”使用 kitty
      xdg.terminal-exec = {
        enable = true;
        settings.default = [ "kitty.desktop" ];
      };
    };
  };
}
