# 外观值的唯一来源。
#
# 不是 Aspect：这里没有自己的配置，只被 den.default 分发成模块参数 `appearance`
# （见 modules/aspects/defaults.nix），各作用域按需取值。
#
# 改光标或图标 fallback 只改这里；四个渲染面与生成的 niri 分片跟着变，
# modules/checks.nix 会断言它们一致。
{
  cursor = {
    theme = "Bibata-Modern-Ice";
    size = 24;
    # niri 桌面会话的隐藏延迟。Dux Greeter 有自己的登录界面行为（0），不取这个值。
    hideAfterInactiveMs = 15000;
  };

  icons = {
    # 登录前 DMS 尚未生成图标主题，登录界面与 GTK 迁移的兜底都用这个值。
    fallback = "Papirus-Dark";
  };
}
