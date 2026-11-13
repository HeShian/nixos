{
  den.aspects.desktop-appearance = {
    nixos = { pkgs, ... }: {
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji

      # 等宽备用字体
      nerd-fonts.jetbrains-mono
      maple-mono.NF

      # Dux Shell / Dux Greeter 的界面与图标字体
      inter
      material-symbols
    ];
  };

    homeManager.imports = [
  # 用户字体
  ({ pkgs, ... }:
      let
        version = "1.2304.79";
        jetbrainsMapleMono = pkgs.runCommand "jetbrains-maple-mono-${version}" {
          nativeBuildInputs = [ pkgs.unzip ];
          src = pkgs.fetchurl {
            url = "https://github.com/SpaceTimee/Fusion-JetBrainsMapleMono/releases/download/${version}/JetBrainsMapleMono-NF-XX-XX-XX.zip";
            hash = "sha256-Wu9Qva7hbUrfNiB7Tw5O77h6T5Y2rrdZWa4yyBM7LHU=";
          };
        } ''
          mkdir -p "$out"
          unzip -j "$src" '*.ttf' -d "$out"
        '';
      in {
        xdg.dataFile."fonts/jetbrains-maple-mono" = {
          source = jetbrainsMapleMono;
          recursive = true;
        };
      })

  # 声明设置与 Qt / GTK 主题依赖
  ({ pkgs, ... }:
      {
        home.packages = [
          pkgs.qt6Packages.qt6ct # DMS 检测到 qt6ct 后启用 Qt 配色。
          pkgs.adw-gtk3
        ];

        # DMS / GTK / Qt 的图标和光标来源（DMS 通过 gsettings 读取）
        dconf.settings."org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "adw-gtk3-dark";
          cursor-theme = "Bibata-Modern-Ice";
          cursor-size = 24;
        };
      })

  # 首启种子：保留已有运行时设置
  ({ config, lib, pkgs, ... }:
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

        # DMS 持有运行时设置。只创建首启种子或补齐缺失的默认值。
        dmsDefaults = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [[ ! -v DRY_RUN ]]; then (
            config_dir=${lib.escapeShellArg config.xdg.configHome}
            config_dir="''${XDG_CONFIG_HOME:-$config_dir}"
            settings="$config_dir/dms/settings.json"
            install -d "$config_dir/dms"

            defaults=${lib.escapeShellArg (builtins.toJSON {
              iconThemeDark = "System Default";
              iconThemeLight = "System Default";
              iconThemePerMode = false;
              cursorSettings = { theme = "Bibata-Modern-Ice"; size = 24; };
              blurredWallpaperLayer = true;
              blurWallpaperOnOverview = true;
            })}

            if [[ ! -L "$settings" ]]; then
              if [[ ! -e "$settings" ]]; then
                # noclobber 避免覆盖恰好由 DMS 创建的文件。
                (set -o noclobber; printf '%s\n' "$defaults" > "$settings") || [[ -f "$settings" ]]
              elif [[ -f "$settings" ]]; then
                snapshot=$(mktemp "$settings.hm-original.XXXXXX")
                updated=
                trap 'rm -f "$snapshot" "''${updated:-$snapshot}"' EXIT
                updated=$(mktemp "$settings.hm-updated.XXXXXX")
                cp -- "$settings" "$snapshot"
                # 只有缺键才生成候选。已有值（含 false/null）全部保留。
                if ${pkgs.jq}/bin/jq -e --argjson defaults "$defaults" '
                  if type == "object" and ($defaults + .) != .
                  then $defaults + . else empty end
                ' "$snapshot" > "$updated" 2>/dev/null \
                  && cmp -s "$settings" "$snapshot"; then
                  chmod --reference="$settings" "$updated"
                  mv -f -- "$updated" "$settings"
                fi
              fi
            fi
          ); fi
        '';
      in
      {
        home.activation.dms-appearance-seed = seed;
        home.activation.dms-theme-defaults = dmsDefaults;
      })

  # 上代遗留迁移：备份与用户设置保护
  ({ config, lib, pkgs, ... }:
      {
        home.activation.gtk-legacy-cleanup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [[ ! -v DRY_RUN ]]; then (
            config_dir=${lib.escapeShellArg config.xdg.configHome}
            config_dir="''${XDG_CONFIG_HOME:-$config_dir}"
            data_dir=${lib.escapeShellArg config.xdg.dataHome}
            data_dir="''${XDG_DATA_HOME:-$data_dir}"
            cache_dir=${lib.escapeShellArg config.xdg.cacheHome}
            cache_dir="''${XDG_CACHE_HOME:-$cache_dir}"
            # 与 matugen 的 folder-icons.sh 共用锁。持锁后才读取 GTK 当前主题。
            install -d "$data_dir/icons"
            exec 9>"$data_dir/icons/.adwaita-matugen.lock"
            ${lib.getExe' pkgs.util-linux "flock"} 9

            read_ini_key() {
              sed -nE "s/^[[:space:]]*$2[[:space:]]*=[[:space:]]*(.*[^[:space:]])[[:space:]]*$/\1/p" "$1" | head -1
            }

            set_ini_key() {
              local file="$1" key="$2" value="$3"
              if grep -Eq "^[[:space:]]*$key[[:space:]]*=" "$file"; then
                sed -i -E "s|^[[:space:]]*$key[[:space:]]*=.*|$key=$value|" "$file"
              elif grep -Eq '^\[Settings\][[:space:]]*$' "$file"; then
                sed -i -E "/^\[Settings\][[:space:]]*$/a $key=$value" "$file"
              else
                printf '\n[Settings]\n%s=%s\n' "$key" "$value" >> "$file"
              fi
            }

            backup=
            for v in 3.0 4.0; do
              dir="$config_dir/gtk-$v"
              install -d "$dir"
              css="$dir/gtk.css"
              settings="$dir/settings.ini"

              icon_theme=
              cursor_theme=
              if [[ -f "$settings" && ! -L "$settings" ]]; then
                icon_theme="$(read_ini_key "$settings" gtk-icon-theme-name)"
                cursor_theme="$(read_ini_key "$settings" gtk-cursor-theme-name)"
              fi

              legacy_css=false
              if [[ -f "$dir/noctalia.css" ]] || { [[ -f "$css" && ! -L "$css" ]] && grep -Eq '^[[:space:]]*@import.*noctalia\.css' "$css"; }; then
                legacy_css=true
              fi
              legacy_theme=false
              case "$icon_theme" in breeze|breeze-dark|Breeze|Breeze-Dark) legacy_theme=true ;; esac
              if [[ "$cursor_theme" == breeze_cursors ]]; then legacy_theme=true; fi
              if $legacy_css || $legacy_theme; then
                if [[ -z "$backup" ]]; then
                  install -d "$cache_dir/nixos-migration-backup"
                  backup=$(mktemp -d "$cache_dir/nixos-migration-backup/gtk-XXXXXXXX")
                fi
                cp -a "$dir" "$backup/gtk-$v"
                if $legacy_css; then rm -f "$dir/noctalia.css" "$dir/noctalia-extensions.css"; fi
              fi

              if [[ ! -L "$css" ]]; then
                if $legacy_css && [[ -f "$css" ]] && grep -Eq '^[[:space:]]*@import.*noctalia\.css' "$css"; then
                  sed -i -E '/^[[:space:]]*@import.*noctalia\.css/d' "$css"
                fi
                if ! grep -Eq '^[[:space:]]*@import.*dank-colors\.css' "$css" 2>/dev/null; then
                  tmp=$(mktemp "$dir/.gtk.css.XXXXXX")
                  {
                    printf '@import url("dank-colors.css");\n'
                    if [[ -f "$css" ]]; then cat "$css"; fi
                  } > "$tmp"
                  mv -f "$tmp" "$css"
                fi
              fi

              if [[ ! -L "$settings" ]]; then
                if [[ ! -e "$settings" ]]; then printf '[Settings]\n' > "$settings"; fi
                case "$icon_theme" in
                  ""|breeze|breeze-dark|Breeze|Breeze-Dark|default|Default)
                    set_ini_key "$settings" gtk-icon-theme-name Papirus-Dark ;;
                esac
                case "$cursor_theme" in
                  ""|breeze_cursors|default|Default)
                    set_ini_key "$settings" gtk-cursor-theme-name Bibata-Modern-Ice ;;
                esac
              fi
            done
          ); fi
        '';
      })
];
  };
}
