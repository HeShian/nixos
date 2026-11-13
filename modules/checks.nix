# 外观值的回归检查：四个渲染面与生成的 niri 分片必须与 modules/_lib/appearance.nix 一致。
#
# 不写死具体值 —— 改光标只改 appearance 模块，检查跟着变；
# 谁把字面量改回某个消费点，检查会在求值阶段失败。
{ self, lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      appearance = import ./_lib/appearance.nix;
      theme = appearance.cursor.theme;
      size = appearance.cursor.size;

      expectEqual = name: expected: actual: {
        inherit name;
        ok = actual == expected;
        detail = "期望 ${toString expected}，实际 ${toString actual}";
      };

      expectInfix = name: needle: haystack: {
        inherit name;
        ok = lib.hasInfix needle haystack;
        detail = "缺少 ${needle}";
      };

      checkedFor =
        host:
        let
          cfg = self.nixosConfigurations.${host}.config;
          user = builtins.head (builtins.attrNames cfg.home-manager.users);
          hm = cfg.home-manager.users.${user};
          greeter = cfg.services.displayManager.dux-greeter.compositor.customConfig;
          fragment = hm.xdg.configFile."niri/appearance.kdl".text;
        in
        [
          (expectEqual "session variable XCURSOR_THEME" theme cfg.environment.sessionVariables.XCURSOR_THEME)
          (expectEqual "session variable XCURSOR_SIZE" (toString size) cfg.environment.sessionVariables.XCURSOR_SIZE)
          (expectEqual "dconf cursor-theme" theme hm.dconf.settings."org/gnome/desktop/interface".cursor-theme)
          (expectEqual "dconf cursor-size" size hm.dconf.settings."org/gnome/desktop/interface".cursor-size)
          (expectInfix "greeter customConfig 的 cursor 主题" "xcursor-theme \"${theme}\"" greeter)
          (expectInfix "greeter customConfig 的 cursor 尺寸" "xcursor-size ${toString size}" greeter)
          (expectInfix "greeter customConfig 的图标兜底" "QS_ICON_THEME \"${appearance.icons.fallback}\"" greeter)
          (expectInfix "生成的 niri 分片" "xcursor-theme \"${theme}\"" fragment)
        ];

      desktopHosts = builtins.filter (
        host:
        let
          cfg = self.nixosConfigurations.${host}.config;
        in
        cfg.services.displayManager.dux-greeter.enable or false
      ) (builtins.attrNames self.nixosConfigurations);

      checkFor =
        host:
        let
          failed = builtins.filter (e: !e.ok) (checkedFor host);
        in
        {
          name = "appearance-${host}";
          value =
            if failed == [ ] then
              pkgs.runCommand "appearance-${host}" { } ''
                echo "外观值与 modules/_lib/appearance.nix 一致：${host}" > $out
              ''
            else
              throw ''
                外观值与 modules/_lib/appearance.nix 不一致（${host}）：
                ${lib.concatMapStringsSep "\n" (e: "  - ${e.name}：${e.detail}") failed}
              '';
        };
    in
    {
      checks = builtins.listToAttrs (map checkFor desktopHosts);
    };
}
