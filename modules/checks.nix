# 外观与 activation 脚本的回归检查。
#
# 值检查不写死具体值：改光标只改 appearance 模块，检查跟着变；谁把字面量改回消费点，
# 检查会在求值阶段失败。脚本检查用临时目录跑真实脚本，断言种子、幂等、干跑与用户设置保留。
{ self, lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      appearance = import ./_lib/appearance.nix;
      scripts = import ./_lib/appearance-scripts.nix pkgs;
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

      # ── activation 脚本：在临时目录里跑真实脚本 ──────────────────────

      seedScriptCheck = pkgs.runCommand "appearance-scripts-seed" { } ''
        set -eu
        home=$TMPDIR/home
        mkdir -p "$home"

        run_seed() {
          local root=$1
          shift
          ${scripts.seed}/bin/seed-appearance \
            --config "$root/.config" \
            --state "$root/.local/state" \
            --pictures "$root/Pictures" \
            --templates "$root/Templates" \
            --wallpaper ${pkgs.writeText "fixture-wallpaper.png" "png"} \
            --bookmarks ${pkgs.writeText "fixture-bookmarks" "file:///tmp"} \
            --shell-template ${pkgs.writeText "fixture-new.sh" "#!/usr/bin/env bash"} \
            --cava-fallback ${pkgs.writeText "fixture-cava" "[color]"} \
            "$@"
        }

        manifest() { find "$1" -type f -print0 | sort -z | xargs -0 sha256sum; }

        # 1. 空家目录：种子全部就位
        run_seed "$home"
        test -f "$home/Pictures/Wallpapers/default.png"
        test -d "$home/Pictures/Screenshots"
        test -f "$home/.config/gtk-3.0/bookmarks"
        test -x "$home/Templates/new.sh"
        test -f "$home/.config/kitty/dank-theme.conf"
        test -f "$home/.config/fuzzel/colors.ini"
        ${pkgs.jq}/bin/jq -e '.wallpaperPath | endswith("Pictures/Wallpapers/default.png")' \
          "$home/.local/state/dms/session.json" > /dev/null

        # 2. 幂等：再跑一遍不改任何文件
        before=$(manifest "$home")
        run_seed "$home"
        [ "$before" = "$(manifest "$home")" ]

        # 3. 已有文件不被覆盖
        echo "user choice" > "$home/.config/cava/themes/matugen"
        run_seed "$home"
        grep -q "user choice" "$home/.config/cava/themes/matugen"

        # 4. 干跑不写盘
        fresh=$TMPDIR/fresh
        mkdir -p "$fresh"
        run_seed "$fresh" --dry-run
        [ -z "$(find "$fresh" -mindepth 1 -print -quit)" ]

        # 5. 参数缺失按用法错误退出
        status=0
        ${scripts.seed}/bin/seed-appearance --config "$fresh" > /dev/null 2>&1 || status=$?
        [ "$status" = 2 ]

        echo "seed-appearance: 种子 / 幂等 / 不覆盖 / 干跑 / 用法错误 全部通过" > $out
      '';

      dmsScriptCheck = pkgs.runCommand "appearance-scripts-dms-defaults" { } ''
        set -eu
        home=$TMPDIR/home
        settings="$home/.config/dms/settings.json"
        defaults=${pkgs.writeText "fixture-dms-defaults.json" (
          builtins.toJSON {
            iconThemeDark = "System Default";
            cursorSettings = {
              theme = "Fixture-Ice";
              size = 24;
            };
            blurredWallpaperLayer = true;
          }
        )}

        run_dms() {
          ${scripts.dmsDefaults}/bin/dms-defaults --settings "$settings" --defaults "$defaults" "$@"
        }

        # 1. 没有文件：写入默认值
        run_dms
        ${pkgs.jq}/bin/jq -e '.cursorSettings.theme == "Fixture-Ice"' "$settings" > /dev/null

        # 2. 幂等
        before=$(sha256sum "$settings")
        run_dms
        [ "$before" = "$(sha256sum "$settings")" ]

        # 3. 缺键补齐，已有值（含 false / null）保留
        ${pkgs.jq}/bin/jq '.cursorSettings = {"theme":"User-Choice","size":32} | del(.blurredWallpaperLayer)' \
          "$settings" > "$settings.next"
        mv "$settings.next" "$settings"
        run_dms
        ${pkgs.jq}/bin/jq -e '.cursorSettings.theme == "User-Choice" and .cursorSettings.size == 32 and .blurredWallpaperLayer == true' \
          "$settings" > /dev/null

        # 4. 坏 JSON：警告、保留原文件、退出 0
        printf 'not json' > "$settings"
        before=$(sha256sum "$settings")
        run_dms 2> "$TMPDIR/warn"
        [ "$before" = "$(sha256sum "$settings")" ]
        grep -q "保留原文件" "$TMPDIR/warn"

        # 5. 干跑不写盘
        rm -rf "$home"
        run_dms --dry-run
        [ ! -e "$settings" ]

        echo "dms-defaults: 种子 / 幂等 / 缺键补齐 / 坏 JSON / 干跑 全部通过" > $out
      '';

      gtkScriptCheck = pkgs.runCommand "appearance-scripts-gtk-legacy" { } ''
        set -eu
        home=$TMPDIR/home
        config="$home/.config"
        data="$home/.local/share"
        cache="$home/.cache"

        run_gtk() {
          ${scripts.gtkLegacyCleanup}/bin/gtk-legacy-cleanup \
            --config "$config" --data "$data" --cache "$cache" \
            --icon-theme "Fixture-Icon" --cursor-theme "Fixture-Cursor" "$@"
        }

        manifest() { find "$home" -type f -print0 | sort -z | xargs -0 sha256sum; }

        # 1. 上代遗留：备份、清理、修复
        mkdir -p "$config/gtk-3.0" "$config/gtk-4.0"
        printf '[Settings]\ngtk-icon-theme-name=Breeze-Dark\ngtk-cursor-theme-name=breeze_cursors\n' \
          > "$config/gtk-3.0/settings.ini"
        printf '/* old */\n' > "$config/gtk-3.0/noctalia.css"
        printf '@import url("noctalia.css");\n' > "$config/gtk-4.0/gtk.css"
        printf '[Settings]\ngtk-theme-name=adw-gtk3-dark\n' > "$config/gtk-4.0/settings.ini"

        run_gtk

        grep -q '^gtk-icon-theme-name=Fixture-Icon' "$config/gtk-3.0/settings.ini"
        grep -q '^gtk-cursor-theme-name=Fixture-Cursor' "$config/gtk-3.0/settings.ini"
        [ ! -e "$config/gtk-3.0/noctalia.css" ]
        [ -d "$cache/nixos-migration-backup" ]
        ls "$cache"/nixos-migration-backup/gtk-* > /dev/null
        grep -q 'dank-colors.css' "$config/gtk-4.0/gtk.css"
        ! grep -q 'noctalia' "$config/gtk-4.0/gtk.css"

        # 2. 幂等
        before=$(manifest)
        run_gtk
        [ "$before" = "$(manifest)" ]

        # 3. 用户自选主题保留
        printf '[Settings]\ngtk-icon-theme-name=My-Icons\ngtk-cursor-theme-name=My-Cursor\n' \
          > "$config/gtk-3.0/settings.ini"
        run_gtk
        grep -q '^gtk-icon-theme-name=My-Icons' "$config/gtk-3.0/settings.ini"
        grep -q '^gtk-cursor-theme-name=My-Cursor' "$config/gtk-3.0/settings.ini"

        # 4. 干跑不写盘
        rm -rf "$home"
        mkdir -p "$home"
        run_gtk --dry-run
        [ -z "$(find "$home" -mindepth 1 -print -quit)" ]

        echo "gtk-legacy-cleanup: 迁移 / 备份 / 幂等 / 保留用户主题 / 干跑 全部通过" > $out
      '';

      # 两个写入者必须算同一个锁路径：Nix 侧的 xdg.dataHome 与会话侧脚本的默认值。
      lockPathIssues =
        builtins.concatMap (
          host:
          let
            cfg = self.nixosConfigurations.${host}.config;
            user = builtins.head (builtins.attrNames cfg.home-manager.users);
            hm = cfg.home-manager.users.${user};
            expected = "${hm.home.homeDirectory}/.local/share";
          in
          lib.optional (hm.xdg.dataHome != expected)
            "${host}: xdg.dataHome 是 ${hm.xdg.dataHome}，而 folder-icons.sh 用 ${expected}"
        ) desktopHosts
        ++ lib.optional
          (!lib.hasInfix "XDG_DATA_HOME:-$HOME/.local/share" (
            builtins.readFile ../dotfiles/.config/matugen/folder-icons.sh
          ))
          "folder-icons.sh 的 XDG_DATA_HOME 默认值已不再与 Nix 侧一致";

      lockPathCheck =
        if lockPathIssues == [ ] then
          pkgs.runCommand "appearance-lock-path" { } ''
            echo "GTK 迁移与 matugen 使用同一个锁路径" > $out
          ''
        else
          throw "外观锁路径不一致：\n${lib.concatMapStringsSep "\n" (i: "  - ${i}") lockPathIssues}";

      # 会话环境：唯一来源是 modules/_lib/session-env.nix，Dotfile 不得再写 environment 块。
      sessionEnv = import ./_lib/session-env.nix { appearance = import ./_lib/appearance.nix; };

      sessionEnvIssues =
        builtins.concatMap (
          host:
          let
            cfg = self.nixosConfigurations.${host}.config;
            actual = cfg.environment.sessionVariables;
            wrong = builtins.filter (k: (actual.${k} or null) != sessionEnv.${k}) (
              builtins.attrNames sessionEnv
            );
          in
          map (
            k: "${host}: ${k} 期望 ${sessionEnv.${k}}，实际 ${toString (actual.${k} or "缺失")}"
          ) wrong
        ) desktopHosts
        ++ lib.optional
          (lib.hasInfix "\nenvironment {" (
            builtins.readFile ../dotfiles/.config/niri/config.kdl
          ))
          "config.kdl 里又出现了 environment {} 块：会话变量应改 modules/_lib/session-env.nix";

      sessionEnvCheck =
        if sessionEnvIssues == [ ] then
          pkgs.runCommand "session-env-single-source" { } ''
            echo "会话环境与 modules/_lib/session-env.nix 一致，Dotfile 未重复承载" > $out
          ''
        else
          throw "会话环境不一致：\n${lib.concatMapStringsSep "\n" (i: "  - ${i}") sessionEnvIssues}";
    in
    {
      checks =
        builtins.listToAttrs (map checkFor desktopHosts)
        // {
          appearance-scripts-seed = seedScriptCheck;
          appearance-scripts-dms-defaults = dmsScriptCheck;
          appearance-scripts-gtk-legacy = gtkScriptCheck;
          appearance-lock-path = lockPathCheck;
          session-env-single-source = sessionEnvCheck;
        };
    };
}
