let
  mkSessionEnv = import ../../_lib/session-env.nix;
in
{
  # niri 图形会话及音频支持。
  den.aspects.niri.nixos.imports = [
  # 合成器、XWayland、会话环境与终端
  ({ pkgs, appearance, ... }: {
        programs.niri.enable = true;

        # nixpkgs 的 niri 模块默认关闭 wayland-session 里的 XWayland。
        # niri 按需启动 xwayland-satellite，并为 X11 客户端设置 DISPLAY。
        programs.xwayland.enable = true;
        environment.systemPackages = [ pkgs.xwayland-satellite ];

        # 会话环境只有这一处写入点，表在 modules/_lib/session-env.nix。
        # 用 sessionVariables：它进 PAM 会话，niri 与 systemd 用户管理器都能拿到。
        environment.sessionVariables = mkSessionEnv { inherit appearance; };

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
