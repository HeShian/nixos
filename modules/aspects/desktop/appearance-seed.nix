{
  # 外观的「首启种子」：只在文件不存在时写入初始值，之后由 DMS 自己维护。
  # 必须幂等——每次 home-manager 激活都会执行。
  den.aspects.desktop-appearance-seed.homeManager =
    { config, lib, pkgs, ... }:
    let
      defaultWallpaper = pkgs.nixos-artwork.wallpapers.catppuccin-mocha.gnomeFilePath;
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
      home.activation.dms-theme-defaults = dmsDefaults;
    };
}
