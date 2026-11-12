{ den, ... }:
{
  # 桌面整体：niri + Dux Shell + Dux Greeter。
  # dotfiles 的活链接按主机区分（acer 用仓库路径，VM 用 flake store），
  # 所以 dotfiles-live / dotfiles-store 分别由 hosts 引入，不放在这里。
  den.aspects.desktop.includes = with den.aspects; [
    niri
    dux-shell
    dux-greeter
    desktop-appearance-seed
    desktop-gtk-legacy
    desktop-appearance-settings
    desktop-packages
    desktop-mimeapps
    desktop-app-integrations
    desktop-terminal
    desktop-locale
    desktop-input-method
    xdg-user-dirs
    desktop-fonts
    desktop-audio
    desktop-flatpak
    clash-verge
  ];
}
