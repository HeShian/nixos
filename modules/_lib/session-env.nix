# 会话环境表：登录会话导出的变量，唯一来源。
#
# 不是 Aspect：只导出 attrset，由 niri Aspect 写到 environment.sessionVariables 一次。
# Dotfile 的 niri environment{} 块已删除 —— 系统环境本来就随 niri 进程继承，
# 那个块只是同一批值的第二份（且 systemd 启的应用拿不到）。
#
# LANG 不在这里：它由 i18n.defaultLocale 产生，属于系统 locale，不是会话环境。
{ appearance }:
{
  # 输入法。GTK_IM_MODULE 与 LANGUAGE 原先只写在 Dotfile 的 niri environment{} 里，
  # 所以由 systemd 启动的应用拿不到；现在统一由会话环境提供。
  LANGUAGE = "zh_CN:en";
  XMODIFIERS = "@im=fcitx";
  GTK_IM_MODULE = "fcitx";
  QT_IM_MODULE = "fcitx";
  QT_IM_MODULES = "wayland;fcitx";
  SDL_IM_MODULE = "fcitx";

  # Wayland 原生提示
  NIXOS_OZONE_WL = "1";
  MOZ_ENABLE_WAYLAND = "1";

  # 默认程序
  EDITOR = "nvim";
  TERMINAL = "kitty";

  # 光标：值来自 modules/_lib/appearance.nix（ADR-0006）。niri 自己的 cursor{} 由
  # 生成的 appearance.kdl 提供；这里保证 systemd 用户服务等非 niri 子进程也拿到同一个值。
  XCURSOR_THEME = appearance.cursor.theme;
  XCURSOR_SIZE = toString appearance.cursor.size;
}
