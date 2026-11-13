{ den, ... }:
{
  # 图形桌面的完整能力集合；Host 单独选择 Dotfile 链接方式。
  den.aspects.desktop.includes = with den.aspects; [
    niri
    dux
    # Dux Files 独立成 Aspect：换文件管理器时整体换掉这一格（issue #2 第四步）。
    dux-files
    desktop-appearance
    desktop-applications
    desktop-localization
  ];
}
