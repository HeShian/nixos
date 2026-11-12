{ den, ... }:
{
  # 桌面整体：niri + Dux Shell + Dux Greeter。
  # dotfiles 的活链接按主机区分（acer 用仓库路径，VM 用 flake store），
  # 所以 dotfiles-live / dotfiles-store 分别由 hosts 引入，不放在这里。
  den.aspects.desktop.includes = with den.aspects; [
    niri
    dux-shell
    dux-greeter
    desktop-appearance
    desktop-applications
    desktop-terminal
    desktop-localization
    xdg-user-dirs
    desktop-fonts
    desktop-audio
    desktop-flatpak
    clash-verge
  ];
}
