{
  # 外观：首启种子 + 图标/光标主题 + 旧桌面 GTK 配置迁移。
  den.aspects.desktop-appearance.homeManager =
    { config, lib, pkgs, ... }:
    let
      defaultWallpaper = pkgs.nixos-artwork.wallpapers.catppuccin-mocha.gnomeFilePath;
      dmsVsix = pkgs.fetchurl {
        name = "dms-theme-0.0.3.vsix";
        url = "https://raw.githubusercontent.com/duxlabs-dev/dux-shell/9b413296b16721f7679fb62e624cb1ed2433fa58/quickshell/matugen/dms-theme.vsix";
        hash = "sha256-MI1x1wiqvwg/N89oMuNVp0qlRT84ubvuMjtpkX0WKQY=";
      };
      codeThemeSettings = pkgs.writeText "dms-vscode-settings.json" (builtins.toJSON {
        "workbench.colorTheme" = "Dynamic Base16 DankShell";
      });
      cavaFallback = pkgs.writeText "cava-theme-fallback" ''
        [color]
        foreground = 'cyan'
      '';
      gtkBookmarks = pkgs.writeText "gtk-bookmarks" (
        lib.concatStringsSep "\n" (map (path: "file://${lib.replaceStrings [ "%" " " "#" "?" ] [ "%25" "%20" "%23" "%3F" ] path}") (
          (with config.xdg.userDirs; [ documents pictures videos music download ])
          ++ [ config.xdg.configHome config.xdg.dataHome ]
        )) + "\n"
      );
      shellTemplate = pkgs.writeText "new.sh" "#!/usr/bin/env bash\n";

      seed = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        pictures="$HOME/Pictures"
        wallDir="$pictures/Wallpapers"
        dmsState="$HOME/.local/state/dms"

        install -d "$wallDir" "$dmsState" "$pictures/Screenshots"
        install -d "$HOME/.config/dgop" "$HOME/.config/yazi" "$HOME/.config/fastfetch" "$HOME/.config/kitty" "$HOME/.config/fuzzel"
        run install -d "$HOME/.config/cava/themes"
        if [ ! -e "$HOME/.config/cava/themes/matugen" ]; then
          run install -m644 ${cavaFallback} "$HOME/.config/cava/themes/matugen"
        fi
        if [ ! -e "$HOME/.config/gtk-3.0/bookmarks" ]; then
          run install -Dm644 ${gtkBookmarks} "$HOME/.config/gtk-3.0/bookmarks"
        fi
        if [ ! -e ${lib.escapeShellArg "${config.xdg.userDirs.templates}/new.sh"} ]; then
          run install -Dm755 ${shellTemplate} ${lib.escapeShellArg "${config.xdg.userDirs.templates}/new.sh"}
        fi

        # 默认壁纸（DMS 首次启动会用它生成整套配色）
        if [ ! -e "$wallDir/default.png" ]; then
          run cp -f ${lib.escapeShellArg defaultWallpaper} "$wallDir/default.png"
        fi

        # DMS 会话状态：只写一次，后续由 DMS 自己维护
        if [ ! -s "$dmsState/session.json" ]; then
          printf '{\n  "wallpaperPath": "%s"\n}\n' "$wallDir/default.png" > "$dmsState/session.json"
        fi

        # matugen 的输出文件在首次生成前可能不存在，先放空文件避免 include 失败
        # （dgop 的 colors.json 不需要占位：文件缺失时 dgop 用自己的默认配色）
        for f in \
          "$HOME/.config/kitty/dank-theme.conf" \
          "$HOME/.config/kitty/dank-tabs.conf" \
          "$HOME/.config/fuzzel/colors.ini"
        do
          if [ ! -e "$f" ]; then
            : > "$f"
          fi
        done
      '';

      # 旧桌面（noctalia / KDE）留下的 GTK 配置迁移：
      #   - gtk.css 里 @import noctalia.css，会排在 DMS 的 dank-colors.css 之后把配色覆盖掉；
      #   - settings.ini 里的 gtk-icon-theme-name=breeze / gtk-cursor-theme-name=breeze_cursors
      #     指向未安装的主题，GTK 会回退到缺失图标/默认光标。
      # 只在检测到问题时修，并且如果用户后来在 DMS 里选了有效主题则保持不动。
      gtkCleanup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        backup="$HOME/.cache/nixos-migration-backup/gtk-$(date +%Y%m%d-%H%M%S)"

        theme_exists() {
          local name="$1" base
          [ -n "$name" ] || return 1
          local IFS=':'
          for base in ''${XDG_DATA_DIRS:-/usr/share}; do
            [ -n "$base" ] || continue
            [ -d "$base/icons/$name" ] && return 0
            [ -d "$base/themes/$name" ] && return 0
          done
          [ -d "$HOME/.icons/$name" ] && return 0
          [ -d "$HOME/.local/share/icons/$name" ] && return 0
          return 1
        }

        set_ini_key() {
          local file="$1" key="$2" value="$3"
          if grep -q "^$key=" "$file"; then
            sed -i "s|^$key=.*|$key=$value|" "$file"
          else
            sed -i "/^\[Settings\]/a $key=$value" "$file"
          fi
        }

        for v in 3.0 4.0; do
          dir="$HOME/.config/gtk-$v"
          [ -d "$dir" ] || continue

          legacy=false
          if [ -f "$dir/noctalia.css" ]; then legacy=true; fi
          if [ -f "$dir/gtk.css" ] && grep -q 'noctalia' "$dir/gtk.css"; then legacy=true; fi

          if [ "$legacy" = true ]; then
            install -d "$backup"
            cp -a "$dir" "$backup/gtk-$v" || true
            rm -f "$dir/colors.css" "$dir/noctalia.css" "$dir/noctalia-extensions.css"
            printf '@import url("dank-colors.css");\n' > "$dir/gtk.css"
          fi

          # Dux 写入配色文件，GTK 的入口样式保留用户已有的规则。
          css="$dir/gtk.css"
          if [ ! -L "$css" ] && ! grep -q 'dank-colors\.css' "$css" 2>/dev/null; then
            tmp=$(mktemp "$dir/.gtk.css.XXXXXX")
            {
              printf '@import url("dank-colors.css");\n'
              if [ -f "$css" ]; then cat "$css"; fi
            } > "$tmp"
            mv -f "$tmp" "$css"
          fi

          settings="$dir/settings.ini"
          if [ ! -f "$settings" ]; then
            printf '[Settings]\n' > "$settings"
          fi

          icon_theme="$(sed -n 's/^gtk-icon-theme-name=//p' "$settings" | head -1)"
          case "$icon_theme" in
            ""|breeze|breeze-dark|Breeze|Breeze-Dark|default)
              set_ini_key "$settings" gtk-icon-theme-name Papirus-Dark
              ;;
            *)
              if ! theme_exists "$icon_theme"; then
                set_ini_key "$settings" gtk-icon-theme-name Papirus-Dark
              fi
              ;;
          esac

          cursor_theme="$(sed -n 's/^gtk-cursor-theme-name=//p' "$settings" | head -1)"
          case "$cursor_theme" in
            ""|breeze_cursors|default|Default)
              set_ini_key "$settings" gtk-cursor-theme-name Bibata-Modern-Ice
              ;;
            *)
              if ! theme_exists "$cursor_theme"; then
                set_ini_key "$settings" gtk-cursor-theme-name Bibata-Modern-Ice
              fi
              ;;
          esac
        done
      '';

      # 图标由 matugen 更新，DMS 读取系统默认。迁移旧的 Papirus 默认值。
      dmsDefaults = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        settings="$HOME/.config/dms/settings.json"
        install -d "$HOME/.config/dms"

        if [ ! -f "$settings" ]; then
          printf '%s\n' '{"iconThemeDark":"System Default","iconThemeLight":"System Default","iconThemePerMode":false,"cursorSettings":{"theme":"Bibata-Modern-Ice","size":24},"blurredWallpaperLayer":true,"blurWallpaperOnOverview":true}' > "$settings"
        else
          tmp="$settings.hm.$$"
          if ${pkgs.jq}/bin/jq '
            . + (if (.iconThemeDark == "Papirus-Dark" and .iconThemeLight == "Papirus-Dark" and .iconThemePerMode == false) or (has("iconThemeDark") | not)
                 then {"iconThemeDark":"System Default","iconThemeLight":"System Default","iconThemePerMode":false} else {} end)
              + (if has("cursorSettings") then {} else {"cursorSettings":{"theme":"Bibata-Modern-Ice","size":24}} end)
              + (if has("blurredWallpaperLayer") then {} else {"blurredWallpaperLayer":true} end)
              + (if has("blurWallpaperOnOverview") then {} else {"blurWallpaperOnOverview":true} end)
          ' "$settings" > "$tmp" 2>/dev/null; then
            mv "$tmp" "$settings"
          else
            rm -f "$tmp"
          fi
        fi
      '';
    in
    {
      home.activation.dms-appearance-seed = seed;
      home.activation.gtk-legacy-cleanup = gtkCleanup;
      home.activation.dms-theme-defaults = dmsDefaults;

      # Dux 每次换壁纸时更新扩展内的主题文件，扩展需安装到可写的用户目录。
      home.activation.dms-vscode-theme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if ! compgen -G "$HOME/.vscode/extensions/danklinux.dms-theme-*" >/dev/null; then
          run ${lib.getExe pkgs.vscode} --install-extension ${dmsVsix}
        fi
        settings="''${XDG_CONFIG_HOME:-$HOME/.config}/Code/User/settings.json"
        if [ ! -e "$settings" ]; then
          run install -Dm644 ${codeThemeSettings} "$settings"
        fi
      '';

      # DMS / GTK / Qt 的图标和光标来源（DMS 通过 gsettings 读取）
      dconf.settings."org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "adw-gtk3-dark";
        cursor-theme = "Bibata-Modern-Ice";
        cursor-size = 24;
      };
    };
}
