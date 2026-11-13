{ den, ... }:
{
  # 图形桌面的完整能力集合；Host 单独选择 Dotfile 链接方式。
  den.aspects.desktop.includes = with den.aspects; [
    niri
    dux
    desktop-appearance
    desktop-applications
    desktop-localization
  ];
}
